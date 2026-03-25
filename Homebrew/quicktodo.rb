cask "quicktodo" do
  version "0.1.2"
  sha256 "57b7b940f4a797f638e7089b748fb19117c3ba0d4356652906796053df4c98af"

  url "https://github.com/turastory/quicktodo/releases/download/v#{version}/QuickTodo.zip"
  name "QuickTodo"
  desc "Single-file Markdown todo panel for macOS"
  homepage "https://github.com/turastory/quicktodo"

  app "QuickTodo.app"
end
