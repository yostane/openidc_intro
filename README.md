# Open ID Connect and OAuth 2 and for the complete beginner

<!-- TOC -->

- [Open ID Connect and OAuth 2 and for the complete beginner](#open-id-connect-and-oauth-2-and-for-the-complete-beginner)
    - [Introduction](#introduction)
    - [Typical use case (Authorization Grant Flow)](#typical-use-case-authorization-grant-flow)
    - [The authorization code and tokens](#the-authorization-code-and-tokens)
        - [The authorization code](#the-authorization-code)
        - [The access token](#the-access-token)
        - [The refresh](#the-refresh)
        - [The ID token](#the-id-token)
    - [What about OAuth 2](#what-about-oauth-2)
    - [Implementing an OIDC RP and OP](#implementing-an-oidc-rp-and-op)
        - [Adding OIDC authentication to your app](#adding-oidc-authentication-to-your-app)
        - [Creating an OP with OpenShift](#creating-an-op-with-openshift)
    - [Quick note on security](#quick-note-on-security)
    - [Conclusion](#conclusion)
    - [Links](#links)

<!-- /TOC -->

![Logo](assets/openid-logo-wordmark.png)

When we develop web or mobile or apps, we may deal with the authentication of the users. Handling authentication on our own backend adds a lot of responsibility because we are responsible of handling sensible data. Hopefully, there is a way to delegate authentication and authorization to 3rd parties thanks to OpenID Connect. It is a standard protocol that is well suited for mobile apps and web apps. It is also based on another standard called OAuth 2. This post serves as a modest introduction to these standards with a strong focus on OpenID Connect.

## Introduction

OpenID Connect, abbreviated OIDC, is a standard that allows to a program, application or website to identify a user thanks to an authentication server. It also allows to get basic authentication information.

OIDC does not define new protocols for every aspect of the identification. Instead, it relies on OAuth 2, which is a framework that defines how a user can get access to resources, and adds a layer that allows to identify the user and a to provide basic information about him.

> (Identity, Authentication) + OAuth 2.0 = OpenID Connect

Since some OIDC and OAuth 2 terms are different, the following sections use OIDC terms. I will try to indicate the differences between OIDC and OAuth 2 when possible. Rest assured anyway, there will be a section dedicated to OAuth 2.

The next section explains a typical OIDC scenario.

## Typical use case (Authorization Grant Flow)

In this section, we give a typical use case for OIDC where we want to develop a mobile app that only retrieves user information and does communicate with its backend.

Suppose we want to develop a mobile app that allows its end-users to log-in using an OIDC provider (abbreviated OP) and shows basic user information retrieved from that OP. In OIDC terminology, the mobile-app is considered an OIDC client and is called Relying Party or RP. This use case flows as follows:

1. The RP requests the OP to authenticate the user
2. The OP shows a web view that asks the end-user to enter his credentials and validate the fact that he is going to provide authentication information to the RP
3. The OP validates back to the RP with an authorization code that gets exchanged with an Access Token and an ID Token. The RP notifies the end-user that the connexion is successful
4. The RP can request some user info from the RP using the access token

This type of flow is called _Authorization Code Flow_, and OIDC defines 2 other flows which as the _Implicit flow_ and _Hybrid flow_. This humble introduction focuses mainly on the _Authorization Code Flow_.

During the _Authorization Code Flow_, the RP sends these requests to the OP:

- The authorization request which that allows the OP to authenticate the end-user. Its result is an authorization code
- The token request that exchanges the authorization code for an access token, ID token and optionally a refresh token
- The user info request that takes the access token as input and returns information about the user

Each of these requests is called an endpoint. OIDC defines standard endpoints that every OP must provide. Every OP exposes its endpoints in the discovery url which is also part of the OIDC standard. It is a JSON file that contains the different endpoints as well as other information. The discovery allows a RP to dynamically obtain the relevant information about an OP. Here are some discovery urls that you can check right now:

- [Google](https://accounts.google.com/.well-known/openid-configuration)
- [Microsoft](https://login.microsoftonline.com/fabrikamb2c.onmicrosoft.com/v2.0/.well-known/openid-configuration)
- [Yahoo](https://login.yahoo.com/.well-known/openid-configuration)

Here is a snippet of the [Yahoo OIDC discovery](https://login.yahoo.com/.well-known/openid-configuration), where you can see the endpoints explained above:

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

At any time does the RP know about the end-user credentials. Instead, it gets an an authorization code and after that an access token and an ID Token. These are explained in the next section.

## The authorization code and tokens

In OIDC, an authorization code and three types of tokens can be obtained upon successful authentication: **The authorization code**, the **access token**, the **refresh token** and the **ID token**. The first three ones come from OAuth2 while the latter is an addition of OIDC.

### The authorization code

It is a string that is returned upon successful authorization by the end user. Its only purpose is to exchange it with an access token and an ID token. The **The authorization code** is mostly used _Authorization Code Flow_, as its name implies. Other OIDC flows may skip it entirely and directly return the different tokens which we will explain next.

### The access token

The **access token** is the information that allows to query other OIDC endpoints, such as the userInfo endpoint. It also allows to access other protected APIs from the RP. For example, [google allows to use the access token](https://developers.google.com/identity/protocols/OAuth2) to query protected its APIS. The access token is not OIDC specific but emanates from OAuth2 with respect to what I explaied above: _(Identity, Authentication) + OAuth 2.0 = OpenID Connect_.

### The refresh

The refresh token is used to obtain a new ID token or access token when. This avoids repeating the authentication step. However, the refresh token may cause dangerous security breaches and must be manipulated with caution. It is strongly recommended to ditch refresh tokens in web apps or mobile apps because. It can be used although when the RP is a web server because it is much more difficult to attack.

### The ID token

The **ID token** is a [JSON Web Token (JWT)](https://jwt.io/), when decoded, is a JSON file that has information about the end-user and about the authentication itself.

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

The next section shows how to implement add OIDC support to an application.

## What about OAuth 2

OAuth 2 is an industry standard for authorization. It explains a standard way in which third party apps can access protected resources on behalf of the resource owner. This is also called delegation of authorization.

The main difference between OAuth 2 and OIDC is that the former provides authorization (is the user can access a resource) while the latter provides authentication (who is the user). Thus, OAuth 2 defines the _access token_ and the _refresh token_ but does define the _id token_ and the _userinfo_ endpoint.

Since OAuth 2 was there before OIDC, OAuth 2 implementations can provide identification information through OAuth 2 without OIDC _in a non standard way_. For example, [Facebook login](https://developers.facebook.com/docs/facebook-login/overview) relies on OAuth 2 but still provides some identification information.

In addition to the ID token, OIDC standardizes other elements that were not standardized by OAuth2 (scopes, endpoint discovery, and dynamic registration of clients).

In terms of terminology, OAuth 2 introduces different terms listed below:

- Authorization Server: the server that provides authorization (the access token mainly) and implements the OAuth 2 protocol
- Resource owner: the registered user that has protected resources
- The client application: the application that requests authorization and protected resources on behalf of the resource owner
- Resource server: the server that provides protected resources in exchange with an access token. It can either be merged with the authorization server or a totally separate entity (such as a REST API provided by the Client application developer)

The following table tries to give an equivalence between OAuth 2 and OIDC terms:

|                 OAuth2                  | OpenID connect          |
| :-------------------------------------: | ----------------------- |
|           Client application            | Relying party           |
|             Resource owner              | End-user                |
| Authorization Server (OIDC not implied) | OpenID Connect Provider |
|             Resource server             |                         |

OIDC does not add anything specific about the resource server, this may explain why there is no equivalent for this term in OIDC.

## Implementing an OIDC RP and OP

The next two sections provide tips and guidances that allow you to implement a RP and an AS. In the following a RP will be called a client or an OIDC client.

Depending on your need and use case, you may implement an OIDC client or OP or both.

[The official OIDC website lists certified libraries](https://openid.net/developers/certified/) for both the client and the server.

The following paragraph gives a brief explanation of OIDC clients.

### Adding OIDC authentication to your app

An OIDC client is able to communicate with an OP. Particularly, it is able to request the _authorizes_ and _token_ endpoints that allow retrieve the different tokens. The _access token_ may be used to get user information through the user or request other APIs as long as they support the access token as an input.

In terms of security and implementation, there are two great families of OIDC clients:

- Server apps and traditional web apps(or server web apps): server side are globally closed to the outside world and offer none or a few entry points through APIs for example. The authorization grant type with client secret and the password grant type are allowed for this kind of clients.
- Single page apps, desktop apps and mobile apps: these apps mainly execute on the client side. Thus, exchanging secret informations is forbidden in this case. The only two recommended grant types are the authorization grant without user secret and the implicit grand. For example, the AppAuth SDK for Android supports only the authorization grant without user secret.

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

The next section shows how to create an OpenID connect Provider with OpenShift.

### Creating an OP with OpenShift

## Quick note on security

## Conclusion

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
