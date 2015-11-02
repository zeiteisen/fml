
// These two lines are required to initialize Express in Cloud Code.
 express = require('express');
 app = express();

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.get('/hello', function(req, res) {
  res.render('hello', { message: 'Congrats, you just set up your app!' });
});

app.get('/add_fml',
		express.basicAuth('fml', 'gkfjhdi34##'),
		function(req, res) {
	res.render('add_fml', { status: ''});
});

app.post('/add_fml', 
	express.basicAuth('fml', 'gkfjhdi34##'),
	function(req, res) {
	var message = req.body.message;
	if (message.length < 10) {
		res.render('add_fml', { status: "The text have to be longer than 10 characters!"});
	} else {
	   	var Post = Parse.Object.extend("Post");
	    var newPost = new Post();
	    newPost.set("lang", req.body.lang);
	    newPost.set("countDownvotes", 0);
	    newPost.set("countUpvotes", 0);
	    newPost.set("countComments", 0);
	    var User = Parse.Object.extend("User");
		var user = new User();
		user.id = "eQXYYiP83f";
	    newPost.set("owner", user);
	    newPost.set("moderation", "pending");
	    newPost.set("message", req.body.message);
	    newPost.set("hidden", true);
	    var female = req.body.female;
	    if (female === "true") {
	    	newPost.set("female", true);	
	    } else {
	    	newPost.set("female", false);
	    }
	    newPost.set("category", req.body.category);
	    newPost.set("author", req.body.author);
		newPost.save(null, {
			success: function() {
				res.render('add_fml', { status: 'Added: <i>' + req.body.message + '</i>'});
			},
			error: function(error) {
				res.send("error: " + JSON.stringify(error));
			}
		});
	}
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();
