# extract_pitch_averages
# RLS 10/2005
# Modified by Christian DiCanio, 2007
# Borrowed and modified by Daryl Bagley et al., 2019

# Extract array of pitch values in labeled region and computer averages
# over every numintervals in the duration of the region. Write results to
# a text file.

numintervals = 12
#Number of intervals you wish to extract pitch from.

form Extract pitch data from labelled points
   sentence Directory_name: /Directory_name/
   sentence Objects_name: *
   sentence Log_file *
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.01
   positive Record_with_precision 1
   comment From sound to pitch:
   positive Pitch_analysis_time_step 0.005
   positive Minimum_pitch 80
   positive Maximum_pitch 300
endform

#If your sound files are in a different format, you can insert that format instead of aiff below.
Read from file... 'directory_name$''objects_name$'.wav
soundID = selected("Sound")

select 'soundID'
To Pitch... pitch_analysis_time_step minimum_pitch maximum_pitch
pitchID = selected("Pitch")

Read from file... 'directory_name$''objects_name$'.TextGrid
textGridID = selected("TextGrid")
num_labels = Get number of intervals... labeled_tier_number

fileappend 'directory_name$''log_file$'.txt label'tab$'start'tab$'end
for i to numintervals
fileappend 'directory_name$''log_file$'.txt 'tab$''i'
endfor

fileappend 'directory_name$''log_file$'.txt 'newline$'

# for storage of pitch data
for i to num_labels
   select 'textGridID'
   label$ = Get label of interval... labeled_tier_number i
   if length(label$)
      select 'textGridID'
      start     = Get starting point... labeled_tier_number i
      end       = Get end point...      labeled_tier_number i
	  interval  = (end-start)/numintervals
      intvl_num = 1
      position  = start
      fileappend 'directory_name$''log_file$'.txt 'label$''tab$''start''tab$''end''tab$'
      while position <= end
         total     = 0
         number    = 0
         while position < start + intvl_num * interval
            select 'textGridID'
            select 'pitchID'
            hertz  = Get value at time... position Hertz Linear
            if hertz = undefined
	          # do nothing
            else
                  total  = total + hertz
                  number = number + 1
            endif
            position = position + analysis_points_time_step
         endwhile
         average  = total / number
		if total = 0
			average$ = "NA"
        else
			average$ = fixed$(average, record_with_precision)
		endif
		if intvl_num = numintervals
  	      fileappend 'directory_name$''log_file$'.txt
 	           ... 'average$'
		else
   	     fileappend 'directory_name$''log_file$'.txt
   	         ... 'average$''tab$'
		endif
         intvl_num = intvl_num + 1
      endwhile
      fileappend 'directory_name$''log_file$'.txt 'newline$'
   endif
endfor
