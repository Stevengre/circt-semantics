ref: 
- module sources: https://www.chisel-lang.org/docs
- track chisel updates: https://groups.google.com/g/chisel-users/c/vFVW9KgJkwU
- Scastie template: https://scastie.scala-lang.org/FfHRZUF4QuiD7PHTQoWINQ
- scala-cli template source: https://github.com/chipsalliance/chisel/blob/f5f5b902e5806ec1aa0d01857a3f3dbb0dd2dd2c/.github/workflows/build-scala-cli-template/chisel-template.scala


### How to build your own Test Module via Chisel? (Online)
1. Go to [Scastie Template](https://scastie.scala-lang.org/FfHRZUF4QuiD7PHTQoWINQ)
2. Edit the code in the panel
3. Run the code and obtain the firrtl code in the console
### How to build your own Test Module via Chisel (Offline)
1. Install [scala-cli](https://scala-cli.virtuslab.org/install)
2. Copy ./chisel-template/ to your own directory
3. Edit source/chisel-template.scala
4. Edit `MODULE` value in Makefile
5. `make`

