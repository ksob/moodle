# README

A application that connects to Moodle e-learning platform over REST, allowing to generate reports of the following:
* Students that submitted an assignment but have not been graded yet. This report is grouped by the teacher, subject and the topic concerned
* Total number of students that passed all assignments of a particular subject, grouped by both the teacher and the subject 
* Last login date of a teacher

All reports are beging generated in the background using Sidekiq workers.
The user triggering the report generation is being informed over email when processing completes.
All the website content is in Polish. 
You would also need to manually customize the mailers as I've hard coded sender addresses/names. 

What have been used:

* Ruby version
ruby 2.5.1

* Database used
MySQL

* Other system dependencies
Redis must be installed on your system
