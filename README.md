# gridfw-security
user management, path management, roles, security

## Cofiguration:
```javascript
const gSecurity = require('gridfw-security');

const Security = new gSecurity(options);
Security.configure(options);
```

### Options:
login method
```javascript
{
	login: function(ctx, options){
		// login without any verification (be carfull)
		if('id' in options)
			user = await db.getUser({id: options.id});
		else if('password' in options && 'email' in options)
			user = await db.getUserByEmailAndPassword(options.email, options.password);
		else
			throw new Error('Illegal login options');
		return user
	}
}
```

Customize Session management:
! By default, The framework will store the whol user info in the session, use the code bellow to prevent this.
```javascript
{
	saveUser: function(ctx, user){
		await ctx.session.set('user', user.id);
	},
	loadUser: function(ctx){
		var userId = await ctx.session.get('user');
		if(userId)
			return await db.getUser({id: userId})
		else
			return undefined;
	}
}
```


## Autentication:
### Email, password authentication
This enable to authenticate user via email&password

### Authenticate a user with specific context
```javascript
// default method
app.post('/login', Security.authenticate());

// Custom method
app.post('/login', function(ctx){
	try{
		user = await db.getUserByEmailAndPassword({
			email: ctx.data.email,
			password: ctx.data.pass
		});
		if(!user)
			throw 401; //Unauthorized
		await ctx.login(user);
		ctx.info('login', `user logged: ${user}`);
		ctx.sendRedirect('/login-success'); // redirect to success page 
	}catch(err){
		if(err === 401)
			ctx.sendRedirect('/login-fails'); // redirect to fait page
		else throw err
	}
});
```
### get a user without authentication on specific context
```javascript
user = await Security.login({
	email: ctx.data.email
	password: ctx.data.pass
});
```

### logout:
```javascript
app.post('/login', function(ctx){
	await ctx.logout();
	ctx.info('login', `user logged-out: ${ctx.user}`);
	ctx.sendRedirect('/logout-success'); // redirect to success page 
});
```

## Filters

### Gridfw filters
Filters is a Gridfw feature, it enable to select a controller based on additional conditions (other then route path).
Use it if you want to select a controller based on custom conditions (will result 404 error when no controller matched)

```javascript
// Gridfw controller based on path only
app.get('/path/to/src', function controller(ctx){});
```
Gridfw additional filters
```javascript
app.get('/path/to/src', Gridfw.filter(function(ctx){return true || false}))
app.get('/path/to/src', Gridfw.filter(function(ctx){return true || false}), function controller(ctx){})
```

Gridfw security filters
```javascript
app.get('/path', Security.isAuthenticated, function controller(ctx){});
app.get('/path', Security.has((ctx)=> await trueFalseLogic(ctx)), function controller(ctx){});
app.get('/path', Security.has('admin-role'), function controller(ctx){});
```

## Authentication stategies:

### OAuth strategy:
```javascript
// setup provider
Security.oauth({
	name: 'provider',

	tokenURL: 'https://www.provider.com/oauth/request_token',
	accessTokenURL: 'https://www.provider.com/oauth/access_token',
	userAuthorizationURL: 'https://www.provider.com/oauth/authorize',

	consumerKey: 'yourKey',
	consumerSecret: 'yourSecret',
	callbackURL: '/auth/provider/callback'
});
// auth URL
app.get('/auth/provider', Security.authenticate('provider'));

// callback url
app.get('/auth/provider/callback')
	.then(Security.oauth({

		}))
	.then(function success(ctx){})
	.catch(function failure(ctx){})
```

## Events
Security.on('login', function(ctx){});
Security.on('logout', function(ctx){});