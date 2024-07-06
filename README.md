# Native extension for luaproc

Original library here: https://github.com/askyrme/luaproc

The goal of this is to provide simple cross platform multi-process capability for defold. 

Use cases could include:

- Multiple processes on a server (thats what Im using it for)
- Multiple processes for a game - maybe offloading agent or modelling compute to another proc
- Client data streaming - openining multiple input channels to handle different data streams at once.

The example provides a couple of ways this can be used. 