cask "quicktodo" do
  version "0.1.0"
  sha256 "4d932e82b5c34ff62d8e22247f7c79b476afbdee88830e0c306bc6e8f244db16"

  url "https://github.com/turastory/quicktodo/releases/download/v#{version}/QuickTodo.zip"
  name "QuickTodo"
  desc "Single-file Markdown todo panel for macOS"
  homepage "https://github.com/turastory/quicktodo"

  app "QuickTodo.app"
end
