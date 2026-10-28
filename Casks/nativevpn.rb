# frozen_string_literal: true

cask "nativevpn" do
  version "0.4.1"
  sha256 "72c3de61fedf3b8cbe73aa470dbee1a6a024d941eb31f472fa06a2ae651e6b99"

  url "https://github.com/learnathing/nativevpn/releases/download/v#{version}/NativeVPN-#{version}-arm64.pkg"
  name "NativeVPN"
  desc "Client for a limited UniVPN-compatible VPN protocol subset"
  homepage "https://github.com/learnathing/nativevpn"

  livecheck do
    skip "Releases are updated explicitly in this tap"
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
    Ad-hoc signed build; not notarized by Apple.
    Installation requires administrator approval and may be blocked by Gatekeeper.
    Disconnect and quit NativeVPN and vpnctl before upgrading or uninstalling.
    Saved scenes, Keychain passwords and gateway trust are preserved on uninstall.
    Configure your own gateway and account. Cross-machine VPN validation is pending.
  EOS
end
