cask "pnpm-standalone" do
  arch arm: "arm64", intel: "x64"

  version "10.33.2"
  sha256 arm64_linux: "0828e5ee23be89d22bd53cc36e93c181ce9d5c47d75f9fe9bf4bdc7a65c66322",
         x64_linux:  "39d7b6600239712bc9581ea219b17ffef46ba60998779cb717be2e068be029ef"

  url "https://github.com/pnpm/pnpm/releases/download/v#{version}/pnpm-linux-#{arch}"
  name "pnpm (standalone)"
  desc "Fast, disk space efficient package manager (standalone binary)"
  homepage "https://pnpm.io"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "pnpm-linux-#{arch}", target: "pnpm"

  zap trash: [
    "~/.local/share/pnpm",
    "~/.config/pnpm",
    "~/.cache/pnpm",
  ]
end