# AI Vibe Coding Rules For WEB Based Projects

# 📁 Project Structure
## 1. When building a project, use these direcotory structure
```
/project-root
│
├── index.html
├── /css
│   └── styles.css
├── /js
│   └── app.js
├── /images/
├── /media/ (videos and other media assets, including non site specific images)
├── /icons/
├── /fonts
├── /projects
│   ├── /subproject1/
│   │   └── images
│   ├── /subproject2/
│       └── images
└── /components (optional)
```
## 2. Mechatronics Engineering Class Specific Directory structures
```
/project-root
│
├── index.html
├── /images/
└── /mechatronics
    ├── /unit-1/
    │   └── images
    ├── /unit-2/
        └── images
    ├── /unit-n/
        └── images

```
/projects , /unit-1 , will have an /images sub directory, and all image links will be relative to the sub images directory, unless specificly pointing to the root/image directory.  There should not be image link generated to other locations.  

# 🧠 Core Coding Principles

## 1. Separation of Concerns
Separate HTML, CSS, and JavaScript into different files.
- HTML = structure
- CSS = styling
- JavaScript = behavior
- Avoid mixing concerns unless explicitly required

## 2. Semantic HTML First
Use meaningful HTML elements instead of generic `<div>`.

Required elements:
- `<header>`
- `<nav>`
- `<main>`
- `<section>`
- `<article>`
- `<aside>`
- `<footer>`

Rule: Prefer semantic elements over `<div>`.

## 3. JavaScript Standards
- Avoid global variables
- Use const by default, let when needed
- Never use var
- Encapsulate logic in functions/modules

## 4. CSS Standards
- Modular and reusable classes
- Use Flexbox/Grid for layout
- Avoid overly generic class names

## 5. Accessibility
- alt text for images
- labels for inputs
- proper heading hierarchy
- keyboard navigation support

## 6. Responsive Design
- Mobile-first approach
- Flexible units (rem, %, vw, vh)
- Media queries for scaling

## 7. Code Quality
- Small, single-purpose functions
- Clean indentation
- Comment only when needed

## 8. Performance
- Minimize DOM queries
- Avoid heavy loops manipulating DOM
- Use defer for scripts

## 9. Naming Conventions
Use descriptive names:
- userProfileCard
- navMenu
- submitButton

Avoid:
- box1
- tempDiv

## 10. AI Output Expectations
- Provide complete working examples
- Keep code simple and readable
- Avoid unnecessary complexity

---

# 🚀 Optional Advanced Rules
- Use ES Modules when possible
- BEM naming for large CSS projects
- Form validation on client and server side
- Prefer fetch() over older AJAX

