# -u lets you basic auth the user/password
# -H intends to force the respond_to format.text blocks, but may have to be used in conjunction with 
#      http://server/match/5/show.txt for example
# The URL can be the notation appended after moves/ or another format 
# Although GET generally not acceptable, post won't work without the forgery protection
curl -u paulfletter@gmail.com:4 -H "Accept: text/plain" http://localhost:3000/match/5/moves/Qb5

