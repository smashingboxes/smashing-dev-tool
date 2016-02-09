blessed = require 'blessed'
contrib = require 'blessed-contrib'

module.exports = (vantage) ->
  page1 = (screen) ->
    map = contrib.map()

    pic = contrib.picture
      file: './lib/logo1.png'
      cols: 50
      onReady: -> screen.render()
    screen.append pic

  page2 = (screen) ->
    line = contrib.line(
      width: 80
      height: 30
      left: 15
      top: 12
      xPadding: 5
      label: 'Title')
    data = [ {
      title: 'us-east'
      x: [
        't1'
        't2'
        't3'
        't4'
      ]
      y: [
        0
        0.0695652173913043
        0.11304347826087
        2
      ]
      style: line: 'red'
    } ]
    screen.append line
    line.setData data


  vantage
    .command 'dashboard'
    .alias 'dash'
    .description 'Launches user interface'
    .action (args, cb) ->
      screen  = blessed.screen()
      screen.key ['escape', 'q', 'C-c'], (ch, key) ->
        process.exit(0)
      picOps =
        file: './lib/logo1.png'
        cols: 50
        onReady: -> screen.render()
      donutOps =
        label: 'TestDonut'
        radius: 10
        arcWidth: 3
        spacing: 1
        yPadding: 2
        data: [
          {percent: 87, label: 'rcp','color': 'green'}
          {percent: 43, label: 'rcp','color': 'cyan'}
          {percent: 91, label: 'ama','color': 'red'}
        ]

      grid = new contrib.grid(rows: 12, cols: 12, screen: screen)
      #grid.set(row, col, rowSpan, colSpan, obj, opts)
      map = grid.set(0, 0, 4, 4, contrib.picture, picOps)
      box = grid.set(4, 0, 4, 4, blessed.box, {content: 'My Box'})
      donut = grid.set(4, 4, 5, 5, contrib.donut, donutOps)

      screen.render()
