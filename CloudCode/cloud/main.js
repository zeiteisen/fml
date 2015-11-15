require('cloud/app.js');

Parse.Cloud.define("moderatePost", function(request, response) {
	Parse.Cloud.useMasterKey();
	var params = request.params;
	var objectId = params.objectId;
	var moderation = params.moderation;
	var Post = Parse.Object.extend("Post");
	var query = new Parse.Query(Post);
	query.equalTo("objectId", objectId);
	query.first().then(function(post) {
		post.set("moderation", moderation);
		post.set("modMessage", params.modMessage);
		if (moderation === "approved") {
			post.set("author", params.author);
			post.set("message", params.message);
			post.set("releaseDate", new Date());
			post.set("hidden", false);
		}
		return post.save();
	}).then(function(post) {
		var query = new Parse.Query(Parse.Installation);
		query.equalTo("user", post.get("owner"));
		var message = post.get("modMessage");
		return Parse.Push.send({
			where: query,
			data: {
				alert: message
			}
		});
	}).then(function() {
		var Meta = Parse.Object.extend("Meta");
		var query = new Parse.Query(Meta)
		query.equalTo("objectId", "O2nmh15Jh2");
		return query.first();
	}).then(function(metaResult) {
		if (moderation === "approved") {
			metaResult.increment("countNewReleases", 1);
		}
		return metaResult.save()
	}).then(function() {
		response.success();
	}, function(error) {
		response.error(error);
	});
});