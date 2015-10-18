# Complex Analysis / Domain Coloring Demo

$ = require "jquery"
husl = require "husl"
math = require "./math.js"

# Math
# ----------------------------------------------------------------------------
{abs, atan2, cos, floor, sin, sqrt} = Math

f = {}
setF = (options) ->
  # f(z) = 0.5 * z^2
  f.inline = options?.inline
  if f.inline
    f.xy  = (x, y) -> [0.5 * (x * x - y * y), x * y]
    f.arg = (x, y) -> atan2(x *y , 0.5 * (x * x - y * y))
    f.abs = (x, y) -> sqrt(0.5 *(x * x + y * y))
  else
    _f = math.compile("0.5 * (x + i*y) * (x + i*y)").eval
    f.xy = (x, y) ->
      f_z = _f {x, y}
      [f_z.re, f_z.im]
    f.arg = (x, y) -> math.arg _f {x, y}
    f.abs = (x, y) -> math.abs _f {x, y}  

setF inline: true

window.toggleInline = ->
  status = not f.inline
  setF inline: status
  console.log "inline:", status

# Colors
# ------------------------------------------------------------------------------
hueMap = (angle) -> math.mod(angle, 360)

# Mathbox
# ------------------------------------------------------------------------------
$ ->
  mathbox = mathBox
    plugins: ['core', 'controls', 'cursor', 'stats']
    controls:
      klass: THREE.OrbitControls

  window.mathbox = mathbox

  three = mathbox.three
  three.renderer.setClearColor(new THREE.Color(0xFFFFFF), 1.0);

  mathbox.camera
    proxy: true,
    lookAt: [0, 0, 0]
    position: [1.5, 3, 1.5]

  view = mathbox.cartesian
    range: [[-1, 1], [-1, 1], [-1, 1]]

  n = 64
  data = view.area
    width: n + 1
    height: n + 1
    axes: [1, 3]
    expr: (emit, x, y, i, j) ->
      z = f.abs(x, y)
      emit(y, z, x)
    items: 1
    channels: 3

  window.freq = 0.5
  colors = view.area
    axes: [1, 3]
    expr: (emit, x, y, i, j, t) -> 
      h = (0.5 * f.arg(x, y) / π + window.freq * t) * 360
      h = hueMap(h)
      s = 100 * math.min(f.abs(x, y), 1.0)
      l = 50.0
      [r, g, b] = husl.toRGB(h, s, l)
      emit(r, g, b, 1.0)
    width: n + 1
    height: n + 1
    items:  1
    channels: 4

  view.axis
    axis: 1
    end: true
    color: 0x000000
    size: 10
    zBias: -1

  view.axis
    axis: 3
    end: true
    color: 0x000000
    size: 10
    zBias: -1

  view.surface
    points: data
    shaded: false
    lineX: false
    lineY: false
    fill: true
    colors: colors
    color: 0xffffff


