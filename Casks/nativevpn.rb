# frozen_string_literal: true

cask "nativevpn" do
  version "0.3.4"
  sha256 "4a5d5840e6f41de25e84848175374ef009907fd1fcd0b6674b558b51a730d666"

  url "https://github.com/learnathing/nativevpn/releases/download/v#{version}/NativeVPN-#{version}-arm64.pkg"
  name "NativeVPN"
  desc "Client for a limited UniVPN-compatible VPN protocol subset"
  homepage "https://github.com/learnathing/nativevpn"

  livecheck do
    skip "Experimental releases are updated explicitly in this tap"
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  pkg "NativeVPN-#{version}-arm64.pkg"

  uninstall_preflight_steps do
    run "/bin/sh", args: ["-c", <<~SHELL]
      /usr/bin/pgrep -x 'NativeVPN|vpnctl' >/dev/null 2>&1
      result=$?
      if [ "$result" -eq 0 ]; then
        echo 'Disconnect and quit NativeVPN and vpnctl before upgrading or uninstalling.' >&2
        exit 1
      fi
      [ "$result" -eq 1 ] || exit 1
    SHELL
  end

  uninstall launchctl: "dev.lain.NativeVPN.helper",
            script:    {
              executable: "/bin/sh",
              args:       ["-c", <<~SHELL],
                n=0
                while :; do
                  /usr/bin/pgrep -x NativeVPNHelper >/dev/null 2>&1
                  result=$?
                  [ "$result" -eq 1 ] && exit 0
                  [ "$result" -eq 0 ] || exit 1
                  n=$((n+1))
                  [ "$n" -lt 30 ] || exit 1
                  /bin/sleep 1
                done
              SHELL
              sudo:       true,
            },
            pkgutil:   "^dev\\.lain\\.NativeVPN$"

  caveats <<~EOS
    Experimental, ad-hoc signed build; not notarized by Apple.
    Installation requires administrator approval and may be blocked by Gatekeeper.
    Disconnect and quit NativeVPN and vpnctl before upgrading or uninstalling.
    Saved scenes, Keychain passwords and gateway trust are preserved on uninstall.
    Configure your own gateway and account. Cross-machine VPN validation is pending.
  EOS
end
