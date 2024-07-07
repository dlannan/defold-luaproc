# Native extension for luaproc

Original library here: https://github.com/askyrme/luaproc

The goal of this is to provide simple cross platform multi-process capability for defold. 

Use cases could include:

- Multiple processes on a server (thats what Im using it for)
- Multiple processes for a game - maybe offloading agent or modelling compute to another proc
- Client data streaming - openining multiple input channels to handle different data streams at once.

The example provides a couple of ways this can be used. 

## Important Notes

The Lua context that a new process uses is _not_ a Defold context. Which means there are none of the Defold extensions available. This may be expanded in the future. For the moment it is recommended that these processes are used for computational or io.

The example current shows two use cases.

The first use case needs "curl" to be available on your system.

1. Pressing the "1" key three csv files will be downloaded at the same time. The time taken will be reported in the log. Pressing the "2" key will execute downloading the same three files sequentially.
   Importantly, the sequential download does not move the data anywhere so it is quite fast anyway. The luaproc example sends all the data over a channel to potentially be used in another process.

2. Pressing the "3" key shows the loading and rendering of 4 txt files at the same time into the gui hud. This does not really make a great real life use case, since all the data needs to be merged and then rendered to the gui. However, it does show how to use multiple io. The test also only reads 80 characters at a time (to show the data more easily). Larger chunks are _much_ faster (recommend 64K chunks if possible). 

A third example will be added soon to show more computationally intensive examples where each process executes a mandelbrot frame which are then shown in sequence for an animation.
