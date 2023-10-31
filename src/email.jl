# using SMTPClient
"""
    sent_email(subject, message)

    - message == e.g. message = html <h2>An important link to look at!</h2>
                                    Here's an <a href="https://github.com/aviks/SMTPClient.jl">important link</a>

"""
function sent_email(subject::String, message::String)

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
        "./docs/build/index.html",
	]

	body = get_body(to, from, subject, mime_msg; attachments)

	rcpt = to
	resp = send(url, rcpt, from, body, opt)
end
