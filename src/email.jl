# using SMTPClient
function sent_email(subject::String, massage::String)

	# new version
	opt = SendOptions(
		isSSL = true,
		username = "payakornsaksuriya@gmail.com",
		passwd = "dwjz amjf mvtq bydm",
	)

	url = "smtps://smtp.gmail.com:465"
    
    # Example for using message
	# subject = "SMPTClient.jl"
	# message =
	# 	html"""<h2>An important link to look at!</h2>
	# 	Here's an <a href="https://github.com/aviks/SMTPClient.jl">important link</a>
	# 	"""

	mime_msg = get_mime_msg(message)

	to = ["payakornn@gmail.com"]
	from = "payakornsaksuriya@gmail.com"

	attachments = [
		dir("data", "opt_solomon", "balancing_completion_time", "C101-25.json"),
		"/Users/payakorn/.julia/dev/VRPTW/report/report.html",
	]

	body = get_body(to, from, subject, mime_msg; attachments)

	rcpt = to
	resp = send(url, rcpt, from, body, opt)
end
