# Open ID Connect and OAuth 2 and for the complete beginner

![Logo](assets/openid-logo-wordmark.png)

Handling user authentication is common yet critical task in many apps. OpenID Connect and OAuth2 are standard used for that purpose. This post serves as a modest introduction to those protocols.

![Logo](assets/how_authenticate.png)

## Introduction

A frequently used solution is to store the credentials in an on-premises database. This implies an important responsibility for the maintainer of the database.

![Database solution](assets/bdd.png)

Another solution is to delegate authentication and authorization to a 3rd party entity. We then communicate with it using a well-defined protocol such as OpenID Connect and OAuth2.

![OIDC solution](assets/oidc_solution.png)

The next section defines OIDC and OAuth2.

## Definition

OpenID Connect, abbreviated OIDC, is a standard that allows a program, an application or a website to provide login functionality through a server which can be hosted by a different developer or organization.

OIDC does not define new protocols for every aspect of the authentication. Instead, it relies on OAuth 2, which is a framework that defines how a user can get access to resources, and adds a layer that allows to identify the user and a to provide basic identification information about him.

> (Identity, Authentication) + OAuth 2.0 = OpenID Connect

Since some OIDC and OAuth 2 terms are different, the following sections use OIDC terms. I will try to indicate the differences between OIDC and OAuth 2 when possible. Rest assured anyway, there will be a section dedicated to OAuth 2.

What a transition,

## Some OIDC Terminology

Here is some OIDC terminology that will be useful for later:

- **Relying party or RP**: is the application which delegates authentication to a 3rd party using the OIDC protocol.
- **OpenID provider or OP**: is the 3rd party that provides authentication to a RP. Such OP are Google and Yahoo.
- **End-user**: is the user that uses the app and enters his credentials to the OP when requested.

![OIDC terms](assets/oidc_terms.png)

The next paragraphs explain a typical OIDC scenario.

## Typical use case (Authorization Grant Flow)

In this section, we give a typical scenario that shows how OIDC works.

Our use case consists of a mobile app that shows some profile information of the authenticated user. The authentication is delegated to an OP that sends-back a **code** to the mobile app in case of success. This scenario is called **Authorization Grant Flow**.

This use case flows as follows:

![Authorization Grant Flow](assets/grant_flow.png)

1. The end-user opens the app and taps the **log-in** button. The app (which is a RP in the context of OIDC) requests the OP to authenticate the end-user using an authorization request. This request contains different parameters including a **redirection URL** that is important for later use
1. The OP shows a web-view that asks the end-user to login. The OP can ask the user for his login and password, his fingerprint or any other mean used by the OP. The important point here is that the OP has the reins and RP cannot access to any information exchanged in this process.
1. The end-user logs-in by following the instructions of the OP. Those steps depend on the OP implementation as specified earlier.
1. When the authentication finishes, the OP notifies the RP thanks to the **redirection URL**. In case of success, this URL contains an authorization code.
1. The RP exchanges the authorization code with an **Access Token** and an **ID Token**. At this step the RP notifies the end-user that the connexion is successful and shows basic user information available in the **ID token**.

This flow type is called _Authorization Code Flow_ because the OP sends an authorization code to the RP during the redirection. OIDC (and also OAuth2) has other flows such as the _Implicit flow_ and _Hybrid flow_. This humble introduction focuses mainly on the _Authorization Code Flow_.

During the _Authorization Code Flow_, the RP sends these requests to the OP:

- **The authorization request** which allows the OP to authenticate the end-user. Its result is an authorization code (AC) sent through the redirection URL
- **The token request** that exchanges the authorization code for an access token, ID token and optionally a refresh token

Each of these requests is called an endpoint. OIDC (and also OAuth 2) defines standard endpoints that every OP must provide. Every OP exposes its endpoints in a specific page which is also part of the OIDC standard. It is a JSON file that contains the different endpoints as well as other information. The url of this page is called **the discovery url**. The discovery allows a RP to dynamically obtain the relevant information about an OP such as the urls of **the authorization request** and **the token request**. In OIDC terminology, these urls are called **endpoints**

Here are some discovery urls that you can check right now:

- [Google](https://accounts.google.com/.well-known/openid-configuration)
- [Microsoft](https://login.microsoftonline.com/fabrikamb2c.onmicrosoft.com/v2.0/.well-known/openid-configuration)
- [Yahoo](https://login.yahoo.com/.well-known/openid-configuration)

A snippet of the [Yahoo OIDC discovery](https://login.yahoo.com/.well-known/openid-configuration) showing some endpoints is available below:

```javascript
{
  "issuer": "https://api.login.yahoo.com",
  "authorization_endpoint": "https://api.login.yahoo.com/oauth2/request_auth",
  "token_endpoint": "https://api.login.yahoo.com/oauth2/get_token",
  "introspection_endpoint": "https://api.login.yahoo.com/oauth2/introspect",
  "userinfo_endpoint": "https://api.login.yahoo.com/openid/v1/userinfo",
  ...
}
```

I want to highlight a very important point. _Never does the RP know about the end-user credentials_. Instead, it gets an an authorization code (abbreviated AC) which is exchanged with access token and an ID Token.

The different tokens and the AC are explained in the next section.

## The authorization code and tokens

In OIDC (and OAuth 2), different information may be sent by the OP to the RP: **The authorization code**, the **access token**, the **refresh token** and the **ID token**. The first three ones come from OAuth2 while the latter is an addition of OIDC.

### The authorization code

It is a string that is returned upon successful authorization by the end user. Its only purpose is to exchange it with an access token and an ID token. The **The authorization code** is mostly used _Authorization Code Flow_, as its name implies. Other OIDC flows may skip it entirely. Instead, they return the different tokens which we will explain next.

### The access token

The **access token** is the information that allows to query other OIDC endpoints, such as the userInfo endpoint. It also allows accessing other protected APIs from the RP. For example, [google allows to use the access token](https://developers.google.com/identity/protocols/OAuth2) to query its protected APIS. The access token is not OIDC specific but emanates from OAuth2 with respect to what is explained above: _(Identity, Authentication) + OAuth 2.0 = OpenID Connect_.

### The refresh token

The refresh token is used to obtain a new ID token or access token when. This avoids repeating the authentication step. However, the refresh token may cause dangerous security breaches and must be manipulated with caution. It is strongly recommended to ditch refresh tokens in web apps or mobile apps because it can easily recreate the other tokens. Although it can be used when the RP is an isolated web server because, it is much more difficult to attack. Thus, it is useful in a server page app (such as PHP, ASP), where the tokens reside on the server.

### The ID token

The **ID token** is a [JSON Web Token (JWT)](https://jwt.io/) that, when decoded, shows a JSON file that has information about the end-user and about the authentication itself.

Each field of the ID token is called a **Claim**. OIDC defines standard claims and it's possible to provide custom ones. Here is a sample ID token:

```
eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJCcGFDMXItMVFRSEdJbVV5SnQ1dlJGMHYtbGlvbjROblkyaEREY1hUMUtzIn0.eyJqdGkiOiIxNTE1OWI1OC1hMjQxLTQ4YWQtYmNjMS1hYmQwMTUyZDk5YTIiLCJleHAiOjE1NDAyNDQwMTcsIm5iZiI6MCwiaWF0IjoxNTQwMjQzNzE3LCJpc3MiOiJodHRwczovL3Nzby1vaWRjLXRlc3QuMWQzNS5zdGFydGVyLXVzLWVhc3QtMS5vcGVuc2hpZnRhcHBzLmNvbS9hdXRoL3JlYWxtcy9kZW1vIiwiYXVkIjoiY2xvaWRjIiwic3ViIjoiNmIzNWI5ZjMtMzQ3YS00MDhhLWFmMWUtYTdiMDU3M2ZlZTQ4IiwidHlwIjoiSUQiLCJhenAiOiJjbG9pZGMiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiJhOTNkNDBjNS0zMTliLTQxMjQtYTQxYS0xMjYyZjU5NWNlMGIiLCJhY3IiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoidHV0dSJ9.UNQeHa69iVy_BbHRH0lydZ83PDYNN1QzxbozWFObhyJIJ8WJzvbMomYHL2To_5zOJ79fNXcVHWIosfbEyz3RrKJ0SvBfrr6Q9gIQnZYWp91_Ky_TRIt5p2lhumAVSPeZSxgWYCUt9nQgGu_4FAaUcH_xS_499x4yu5cA82gWQUYLw6wrIF-PLwAsAwfibdIV8-3lByA4X9tksuFOEtqzr96FLbNnZ6zldytwJffOYsBRT7efbfKAKgeboT9V1y6Wtf95EsUQkhzRmnaWs-u07xi9IryassoeNMOnaMw0LGvImkcPyqQvcnxtLE4eL4OkWIi7MYqYkIW-kW0YdZrKFw
```

Since it a JWT, it can be decoded using [jwt.io](https://jwt.io/), or the [pyjwt command](https://pyjwt.readthedocs.io/en/latest/) or any other JWT decoder. The result is this JSON file:

```javascript
{
   "sub" : "6b35b9f3-347a-408a-af1e-a7b0573fee48",
   "nbf" : 0,
   "azp" : "cloidc",
   "preferred_username" : "tutu",
   "session_state" : "a93d40c5-319b-4124-a41a-1262f595ce0b",
   "aud" : "cloidc",
   "auth_time" : 0,
   "iat" : 1540243717,
   "jti" : "15159b58-a241-48ad-bcc1-abd0152d99a2",
   "iss" : "https://sso-oidc-test.1d35.starter-us-east-1.openshiftapps.com/auth/realms/demo",
   "acr" : "1",
   "typ" : "ID",
   "exp" : 1540244017
}
```

The **UserInfo** endpoint has more claims than the **ID token**. Thus, it is not necessary to call the userInfo endpoint unless we want a claim not provided by the ID token.

We may not notice, but at this point, many OAuth2 concepts were also covered. The next section highlights OAuth 2 specificities.

## OAuth2

OAuth 2 is an industry standard for authorization. It explains a standard way in which apps can request access to protected resources from a 3rd party on behalf of the resource owner. This is also called delegation of authorization.

### OIDC and OAuth2

OIDC is layer on top OAuth2. The main difference between OAuth 2 and OIDC is that the former provides authorization (is the user can access a resource) while the latter provides authentication (who is the user). Thus, OAuth 2 defines the _access token_ and the _refresh token_ while OIDC adds the _ID token_ and the _userinfo_ endpoint.

Nowadays, we may find OAuth2 implementations that do not support OIDC and do not provide the **ID token**. These implementations can provide identification information through OAuth 2 without OIDC _in a nonstandard way_. For example, [Facebook login](https://developers.facebook.com/docs/facebook-login/overview) relies on OAuth2 but still provides some identification information.

In addition to the **ID token**, OIDC standardizes other elements that were not standardized by OAuth2 (scopes, endpoint discovery, and dynamic registration of clients).

In terms of terminology, OAuth2 has a different vocabulary than OIDC. This may be annoying sometimes but is not insurmountable. Here are some of them:

- **Authorization Server**: the server that provides authorization (the access token mainly) and implements the OAuth 2 protocol
- **Resource owner**: the registered user that has protected resources
- **The client application**: the application that requests authorization and protected resources on behalf of the resource owner
- **Resource server**: the server that provides protected resources in exchange with an access token. It can either be merged with the authorization server or a totally separate entity (such as a REST API provided by the Client application developer).

![OIDC + OAuth terms](./assets/oauth2_oidc_terms.png)

The following table maps OAuth 2 to OIDC terms:

|                 OAuth2                  | OpenID connect          |
| :-------------------------------------: | ----------------------- |
|           Client application            | Relying party           |
|             Resource owner              | End-user                |
| Authorization Server (OIDC not implied) | OpenID Connect Provider |
|             Resource server             |                         |

OIDC does not have a vocabulary related to the resource server because it focuses on identification side.

### Calling a protected API using OAuth2/OIDC

Up until now, we have put aside the communication with any protected Rest API. This was purposely done for different reasons. The first one is to avoid addressing authentication and authorization at once. The second one is that this part is related to the authorization which is originally provided by OAuth2. Now that we have basic knowledge about OAuth2, I can suggest a common way for communicating with a protected API which is valid in both OIDC and OAuth2 worlds.

Basically, a protected API requires some kind of authorization process before allowing the user to access the resource. This can be achieved in different ways, for example by sending credentials or a specific token in the request parameters. The server then checks the validity of authorization information and replies to the client back by either a success response or by an access denied response.

In OAuth2/OIDC, the authorization information is the **access token**. The following figure illustrated calling a protected API using the access token.

![Calling protected API](./assets/oauth_ressource_server.png)

1. The client application authenticated the user with either OAuth2 or OIDC protocols using one of the available flows (for example the authorization grant flow that we have seen earlier)
2. The client application sends a request to a protected API by adding the

## Implementing an OIDC RP and OP

The next two sections provide tips and guidance that allow implementing a RP and an AS. In the following a RP will be called a client or an OIDC client.

Depending on your need and use case, you may implement an OIDC client or OP or both.

[The official OIDC website lists certified libraries](https://openid.net/developers/certified/) for both the client and the server.

The following paragraph gives a brief explanation of OIDC clients.

### OIDC RP libraries

An OIDC client is able to communicate with an OP. Particularly, it is able to request the _authorizes_ and _token_ endpoints that allow retrieve the different tokens. The _access token_ may be used to get user information through the user or request other APIs as long as they support the access token as an input.

In terms of security and implementation, there are two great families of OIDC clients:

- Server apps and traditional web apps(or server web apps): server side are globally closed to the outside world and offer none or a few entry points through APIs for example. The authorization grant type with client secret and the password grant type are allowed for this kind of clients.
- Single page apps, desktop apps and mobile apps: these apps mainly execute on the client side. Thus, exchanging secret information is forbidden in this case. The only two recommended grant types are the authorization grant without user secret and the implicit grand. For example, the AppAuth SDK for Android supports only the authorization grant without user secret.

Note: _There are security aspects that must be considered, but they are outside the scope of this humble introduction_

Hopefully, thanks to the popularity of OIDC, we can fairly easily find SDKs and tutorials that help us implement an OIDC client. For example, the AppAuth SDK for iOS and Android provides a simple interface for requesting endpoints and persisting authentication information. It also handles all interaction with the OP for us.

Here are some SDKs that help us implement an OIDC client or RP:

- Server apps and traditional web apps(or server web apps):
  - PHP: [PHP OpenID Connect Basic Client](https://github.com/jumbojett/OpenID-Connect-PHP)
  - Node: [Node openid-client](https://www.npmjs.com/package/openid-client)
  - JEE + Spring: [OAuth 2.0 Login Sample](https://github.com/spring-projects/spring-security/tree/5.0.0.RELEASE/samples/boot/oauth2login)
- Single page apps, desktop apps and mobile apps:
  - iOS and macOS: [AppAuth for iOS and macOS](https://github.com/openid/AppAuth-iOS)
  - Android: [AppAuth for Android](https://github.com/openid/AppAuth-Android)
  - Javascript: [AppAuth for JS](https://github.com/openid/AppAuth-JS)
  - Angular: [angular-auth-oidc-client](https://github.com/damienbod/angular-auth-oidc-client)

Many more libraries and code sample are available. I have also developed bash scripts that play with OIDC using curl [here](set_vars_template.sh), [here](password_req.sh) and [here](code_to_token_req.sh).

The next section provides some tracks for building an OIDC provider.

### Building an OIDC OP

As the famous motto says "Don't reinvent the wheel", I am not going to show how to build an OP from scratch. In fact, there are already many available ones as two flavours. The first one is OP libraries that can be plugged to an existing server to provide OP features. The second one is a full-fledged OP server that bundles an OP in a nearly ready to deploy server.

Similarly to RP, the official [OIDC website provides links to reference implementations for both servers and libraries](https://openid.net/developers/certified/).

One famous server is [Kecloack](https://www.keycloak.org/) which provides an very user friendly UI for configuring nearly every aspect of it.

In addition to that, the free plan of [Redhat OpenShift](https://www.openshift.com/) allows to easily deploy a Keycloack server. So, there is no excuse to start toying with OIDC.

It is now time to conclude this post.

## Conclusion

OpenID Connect and OAuth2 are protocols that allow developers to delegate authentication and authorization to a third party entity. This article explained some key principles and terms related to those technologies such as the A. It also illustrated a common use case of a mobile app using the authorization grant flow. The next step consists of putting all that into practice. For that goal, I provided some useful links. Maybe I'll crate another tutorial for that :).

## Links

- [https://openid.net/connect/](https://openid.net/connect/)
- [List of public OpenID Connect providers](https://connect2id.com/products/nimbus-oauth-openid-connect-sdk/openid-connect-providers)
- [OpenID Connect (Authorization Code Flow) with Red Hat SSO](https://medium.com/@robert.broeckelmann/openid-connect-authorization-code-flow-with-red-hat-sso-d141dde4ed3f)
- [Execute an Authorization Code Grant Flow](https://auth0.com/docs/api-auth/tutorials/authorization-code-grant)
- [Trying out OAuth2 via CURL](https://labs.cx.sap.com/2012/06/18/trying-out-oauth2-via-curl/)
- [Curl output to display in the readable JSON format in UNIX shell script](https://stackoverflow.com/questions/27238411/curl-output-to-display-in-the-readable-json-format-in-unix-shell-script)
- [Assigning the output of a command to a variable](https://stackoverflow.com/questions/20688552/assigning-the-output-of-a-command-to-a-variable)
- [How to parse JSON string via command line on Linux](http://xmodulo.com/how-to-parse-json-string-via-command-line-on-linux.html)
- [pyjwt](https://pyjwt.readthedocs.io/en/latest/)
- [Identity, Claims, & Tokens – An OpenID Connect Primer, Part 1 of 3](https://developer.okta.com/blog/2017/07/25/oidc-primer-part-1)
- [Why use OpenID Connect instead of plain OAuth2?](https://security.stackexchange.com/questions/37818/why-use-openid-connect-instead-of-plain-oauth2)
