# telescope-gott.nvim

> A nvim go test runner based on [gott@v2.x.x](https://github.com/sshelll/gott) and [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).



## Demo

![demo](./img/demo.jpg)



## Requirements

1. [gott@v2.x.x](https://github.com/sshelll/gott) (required)

> `go install github.com/sshelll/gott/v2@latest`

2. [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)

> `Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }`

3. [gott.nvim](https://github.com/sshelll/gott.nvim) (optional, but highly recommend)
> `Plug 'sshelll/gott.nvim'`


## Install

use your nvim plug manager, for example:

`Plug 'sshelll/telescope-gott.nvim'`



## Setup

```lua
require('telescope').load_extension('gott')
```



## Usage

1. `:Telescope gott` , use this command to open the test selector.
2. `:lua require('notify').dismiss()`, use this command to clear the test result pop-up notifications.

> It's recommended to make your own custom key map or cmd for the 2nd command.
>
> Also note that the 2nd command will clear all notifications made by the 'notify' plug.
>
> If you have `gott.nvim` installed, you can use `:GottClear` instead of the 2nd command.



## Tips!

There's similar tool to run test - [gott.nvim](https://github.com/sshelll/gott.nvim).

The main difference between `gott.nvim` and `telescope-gott.nvim` is that `gott.nvim` provides a vim cmd to run the test under the cursor, while `telescope-gott.nvim` provides a interactive way to choose a go test to run.
