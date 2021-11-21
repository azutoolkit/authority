---
description: >-
  This document describes the syntax and semantics of the template engine and
  will be most useful as a reference to those modifying the Authority templates.
  As the template engine is very flexible.
---

# User Interface

The Managed UI implements screens such as login, registration, account recovery, account setting, and account verification. This allows for fast adoption of Authority.

Contrary to other vendors, Authority allows you to implement your own UI by offering simple HTML templates. You can change the look of Authority `signin` and `authorize` HTML pages.

### The Public directory

The public directory contains all the front-end CSS and HTML-related files that compose the user interface for Authority. These are small easy to understand files that are clearly named for easy adoption.

Just edit the `./public/templates/signin.html` and `./public/templates/authorize.html`

### `HTML (jinja) Templates`

A template contains **variables** and/or **expressions**, which get replaced with values when a template is _rendered_; and **tags**, which control the logic of the template.&#x20;

Below is a minimal template that illustrates a few basics using the default Jinja configuration. We will cover the details later in this document:

```django
{% extends "layout.html" %}
{% set title = "Signin" %}

{% block body %}
<main class="login-form">
  {% include "errors.html" %}
  <form action="/signin" method="post">
    <input type="hidden" name="forward_url" id="forward_url" value="{{forward_url}}">
    <div class="avatar"><i class="material-icons">&#xE7FF;</i></div>
    <h4 class="modal-title">Login to Your Account</h4>
    <div class="form-group">
      <input type="text" class="form-control" id="username" name="username" placeholder="Username" required="required">
    </div>
    <div class="form-group">
      <input type="password" class="form-control" id="password" name="password" placeholder="Password"
        required="required">
    </div>
    <div class="form-group small clearfix">
      <label class="form-check-label"><input type="checkbox">Remember me</label>
      <a href="/forgot-password" class="forgot-link">Forgot Password?</a>
    </div>
    <div class="d-grid gap-2 mx-auto">
      <input type="submit" class="btn btn-primary" id="signin" value="Login">
    </div>
  </form>
  <div class="text-center small">Don't have an account? <a href="/register">Sign up</a></div>
</main>
{% endblock %}
```

{% hint style="info" %}
Learn more about the template syntax and capabilities at [https://jinja.palletsprojects.com/en/3.0.x/templates/](https://jinja.palletsprojects.com/en/3.0.x/templates/) and [https://shards.info/github/straight-shoota/crinja](https://shards.info/github/straight-shoota/crinja)
{% endhint %}
