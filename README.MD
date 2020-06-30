# create-rbx-fun

Template for Roblox project that uses Fun Framework

_This template is for **1** place only_

## Prerequisites

- Setup Development Environment using VSCode with Rojo

  - Install [Rojo Plugin](https://www.roblox.com/library/1997686364/Rojo-0-5-4) in Roblox studio
  - Install `rojo CLI`:
    - macOS with [Rust Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
  - Or Install Rojo's VSCode Extension (For macOS users, [Rust Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html) must be installed first)
  - References
    - [Setup with Sublime on Windows](https://medium.com/roblox-development/setting-up-roblox-development-with-rojo-git-sublime-text-3-and-luacheck-from-scratch-fb2ad65c7fa7)
    - [Setup with VSCode](https://medium.com/@OverHash/roblox-development-in-visual-studio-code-b3010c3d0181)

## Instructions

1. Clone/Fork this repository to use as a [Github Template Repository](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template)
2. replace project name with your project name
3. configure `default.project.json`

   - change the name of the place in `default.project.json` 's name property
   - **For Published Project Only:**

     - Set `servePlaceIds` with the working place ID
       if there are 2 or more projects running concurrently, set a different port.
       - e.g 34800, 34900
     - Set servePlaceIds with the Published Project's working place ID

   Sample Configuration (ignore `servePort` and `servePlaceIds` settings for a fresh project):

   ```json
   {
     "name": "PlaceName",
     "tree": {
       "$path": "src"
     },
     "servePort": 34800,
     "servePlaceIds": [5038256761]
   }
   ```

   [Reference](https://rojo.space/docs/0.5.x/reference/project-format/)

4. In terminal, start up rojo server:  
   `rojo serve`

5. Open the place in `build` folder

6. In Roblox studio, click on rojo plugin and enter the server port to connect with rojo server
7. Have fun creating! Remember to save the place file for git version control every 15 minutes.
