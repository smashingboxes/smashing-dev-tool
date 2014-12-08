weaveeup-angular-client
======================

[![Build Status](https://magnum.travis-ci.com/smashingboxes/weaveup-angular-client.svg?token=UXcjT4VgrwApWHZhXXAk&branch=master)](https://magnum.travis-ci.com/smashingboxes/weaveup-angular-client)

# WeaveUp Custimization Tool

## Getting Started

### Intallation

Install the package
`bower install https://github.com/smashingboxes/weavup-angular-client --save`

Include it in your project
`<link rel="stylesheet" href="path/to/client/weavup-customizer.css" />`
`<script src="path/to/client/weaveup-customizer.js"></script>`

For now, you should also copy all the images from the `path/to/client/images`
directory. You can easily set up a grunt task to do this.

### Usage

```html
<weaveup-customizer
  design-config="customizeDesign"
  on-close="closeThisSomehow()"
  on-complete="completeThisSomehow(designSettings)"></weaveup-customizer>
```

The design-config expects an object in the following format

```js
{
  drawing: {
    svg: "an svg file",
    original_color_way: [colorWay]
  },
  colorWay: [colorWay],
  repeatCount: 5,
  repeatType: "half-brick"
}
```

_Note: the design-config object must already be populated with data when this
directive is loaded_

When complete it calls the `on-complete` function with the following
designSettings object

```js
{
  colorWay: [newColorWay],
  repeatCount: 5,
  repeatType: "half-drop",
  rasterUrl: "blob:http://localhost/raster-image"
}
```

The current supported repeat types are `basic, half-drop, half-brick, center`

### Example
Check out the example app in this repository
