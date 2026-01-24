# Branding

Customize Authority's visual identity for your organization.

## Logo

### Replace Logo

Place your logo in the public directory:

```
public/images/logo.png
public/images/logo-dark.png  # For dark backgrounds
public/images/favicon.ico
```

### Logo Requirements

| Type | Size | Format |
|------|------|--------|
| Logo | 200x50px | PNG, SVG |
| Logo (dark) | 200x50px | PNG, SVG |
| Favicon | 32x32px | ICO, PNG |
| Apple Touch | 180x180px | PNG |

### Template Usage

```html
<img src="/images/logo.png" alt="{{ app_name }}" class="logo">
```

## Colors

### Primary Colors

Customize in `public/css/styles.css`:

```css
:root {
  /* Brand colors */
  --primary-color: #7c3aed;      /* Primary purple */
  --primary-hover: #6d28d9;      /* Darker purple */
  --primary-light: #a78bfa;      /* Lighter purple */

  /* Accent colors */
  --accent-color: #06b6d4;       /* Cyan accent */

  /* Status colors */
  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
  --info: #3b82f6;
}
```

### Dark Theme (Default)

```css
:root {
  --bg-primary: #0f172a;
  --bg-secondary: #1e293b;
  --bg-card: #1e293b;
  --text-primary: #f8fafc;
  --text-secondary: #94a3b8;
  --border-color: #334155;
}
```

### Light Theme

```css
.theme-light {
  --bg-primary: #ffffff;
  --bg-secondary: #f8fafc;
  --bg-card: #ffffff;
  --text-primary: #0f172a;
  --text-secondary: #64748b;
  --border-color: #e2e8f0;
}
```

## Application Name

### Configuration

```bash
APP_NAME=MyAuth
APP_TAGLINE=Secure authentication for everyone
```

### Template Usage

```html
<title>{{ app_name }} - Sign In</title>
<p>{{ app_tagline }}</p>
```

## Custom Fonts

### Google Fonts

```html
<!-- In layout.html -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

```css
:root {
  --font-family: 'Inter', system-ui, sans-serif;
}

body {
  font-family: var(--font-family);
}
```

### Self-Hosted Fonts

```css
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
}
```

## Login Page

### Background Image

```css
.login-page {
  background-image: url('/images/login-bg.jpg');
  background-size: cover;
  background-position: center;
}
```

### Login Card

```css
.login-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  padding: 2rem;
}
```

## Email Branding

### Email Header

```html
<!-- emails/base.html -->
<div class="header" style="background-color: #7c3aed; padding: 20px; text-align: center;">
  <img src="{{ base_url }}/images/logo-dark.png" alt="{{ app_name }}" style="max-width: 150px;">
</div>
```

### Email Footer

```html
<div class="footer" style="text-align: center; padding: 20px; color: #666;">
  <p>&copy; {{ year }} {{ company_name }}. All rights reserved.</p>
  <p>{{ company_address }}</p>
</div>
```

## OAuth Consent Page

### Client Branding

Show client logos on consent page:

```html
<div class="client-info">
  {% if client.logo_uri %}
  <img src="{{ client.logo_uri }}" alt="{{ client.name }}" class="client-logo">
  {% endif %}
  <h2>{{ client.name }}</h2>
</div>
```

### Scope Icons

```html
<ul class="scopes">
  {% for scope in scopes %}
  <li>
    <i class="icon icon-{{ scope.name }}"></i>
    {{ scope.description }}
  </li>
  {% endfor %}
</ul>
```

## Configuration Reference

```bash
# Branding
APP_NAME=MyAuth
APP_TAGLINE=Secure authentication
COMPANY_NAME=My Company
COMPANY_ADDRESS=123 Main St, City

# URLs
LOGO_URL=/images/logo.png
FAVICON_URL=/images/favicon.ico
TERMS_URL=https://example.com/terms
PRIVACY_URL=https://example.com/privacy
SUPPORT_URL=https://example.com/support

# Theme
THEME=dark  # dark or light
PRIMARY_COLOR=#7c3aed
```

## Best Practices

{% hint style="success" %}
**Do:**

- Use consistent brand colors
- Maintain good contrast ratios
- Test on mobile devices
- Include alt text for images
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Low contrast text
- Very small fonts
- Overly complex layouts
- Slow-loading images
{% endhint %}

## Next Steps

- [UI Templates](templates.md) - Template customization
- [Email Templates](email-templates.md) - Email branding
- [SSL Certificates](../configuration/ssl-certificates.md) - HTTPS setup
