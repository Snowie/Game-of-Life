import graphfield, times, sdl2, sets

proc renderHexField(n: Node, nSet: var HashSet[Node], ren: RendererPtr) =
  if n.state.current:
    var r: Rect
    r.x = cast[cint](n.position.x + 1)
    r.y = cast[cint](n.position.y + 1)
    r.w = 2
    r.h = 2
    setDrawColor(ren, uint8(255), uint8(255), uint8(255))
    fillRect(ren, r)
    setDrawColor(ren, uint8(0), uint8(0), uint8(0))

  nSet.incl(n)

  for i in 0..<len(n.neighbours):
    if n.neighbours[i] == nil:
      continue
    if not nSet.contains(n.neighbours[i]):
      renderHexField(n.neighbours[i], nSet, ren)

proc renderHexField(n: Node, ren: RendererPtr) =
  var nSet: HashSet[Node] = initSet[Node]()
  renderHexField(n, nSet, ren)

proc rules(n: var Node, nSet: var HashSet[Node]) =
  #Calculate what the field will look like next

  nSet.incl(n)

  n.state.future = case sumSelfAndNeighbours(n)
    of 3:
      true
    of 4:
      n.state.current
    else:
      false

  for i in 0..<len(n.neighbours):
    if n.neighbours[i] != nil:
      if not nSet.contains(n.neighbours[i]):
        rules(n.neighbours[i], nSet)

proc main() =
  let width: int = 400
  let height: int = 200
  let sides: int = 10
  var field: Node  = initRandomField(width, height, sides)

  #Setup SDL
  var
    win: WindowPtr
    ren: RendererPtr
    evt = sdl2.defaultEvent
    runGame = true


  discard init(INIT_EVERYTHING)

  win = createWindow("Conway's Game Of Life: Hex Edition", 100, 100, 1280, 720, SDL_WINDOW_SHOWN)
  let cellMod = min(1280 div cast[int](width), 720 div cast[int](height))

  if win == nil:
    echo("Create window failed! Error: ", getError())
    quit(1)

  ren = createRenderer(win, -1, Renderer_Accelerated)
  if ren == nil:
    echo("Create renderer failed! Error: ", getError())
    quit(1)

  var timeStart = epochtime()

  var generations= 3_000

  for i in 0..generations:
    #Handle Events
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break

    if not runGame:
      break

    #Determine how the field will look for the next generation
    field.logic(rules)

    ren.clear

    setDrawColor(ren, uint8(0), uint8(0), uint8(0))
    renderHexField(field, ren)
    setDrawColor(ren, uint8(0), uint8(0), uint8(0))

    #Draw to the screen
    ren.present

    #Move the field's future to current
    field.step()

  var timeStop = epochtime()

  echo("Program time: ", timeStop-timeStart)
  echo("Dataset: ", width * height)
  echo("Generations per second: ", float(generations)/(timeStop-timeStart))
  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
