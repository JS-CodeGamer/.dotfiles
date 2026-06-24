# pass + Tomb + GitHub workflow

This workflow keeps the GPG private key and local password-store checkout inside a Tomb. The GitHub repository only receives `pass`'s encrypted `.gpg` entries and git metadata.

## Security model

- The Tomb contains:
  - `gnupg/`: the private GPG keyring used only for `pass`
  - `password-store/`: the local `pass` git working tree
- GitHub contains:
  - encrypted password files
  - entry names, folder names, commit times, and commit messages
- Use bland entry names if metadata matters. For example, `web/mail` leaks less than `gmail/jagteshver-primary`.
- Do not store the Tomb key file in the password-store repo. Keep the Tomb file and Tomb key backed up separately.

## One-time packages on Arch

Check what is already available:

```sh
pass-tomb deps
```

Install anything missing in a real terminal:

```sh
sudo pacman -S --needed pass
yay -S --needed tomb
```

`git`, `gpg`, `pinentry`, and `gh` are already installed on the current machine.

## Tomb layout

Default paths used by the `pass-tomb` helper:

```sh
PASS_TOMB_FILE="$HOME/Vaults/passwords.tomb"
PASS_TOMB_MOUNT="$HOME/.local/share/pass-tomb/mount"
PASS_TOMB_KEY_GNUPGHOME="$HOME/.local/share/pass-tomb/tomb-key-gnupg"
PASS_TOMB_GNUPGHOME="$PASS_TOMB_MOUNT/gnupg"
PASS_TOMB_STORE="$PASS_TOMB_MOUNT/password-store"
PASS_TOMB_BRANCH=main
```

`PASS_TOMB_KEY_GNUPGHOME` is outside the Tomb on purpose. It is only a clean GPG runtime home for Tomb's own key encryption/decryption, so Tomb does not depend on the default `~/.gnupg`. The pass private key still lives at `PASS_TOMB_GNUPGHOME` inside the mounted Tomb.

If your Tomb key is a separate file:

```sh
export PASS_TOMB_KEY="$HOME/Vaults/passwords.tomb.key"
```

Put persistent overrides in a private local shell file, not in public dotfiles:

```sh
mkdir -p "$HOME/.config/pass-tomb"
chmod 700 "$HOME/.config/pass-tomb"
$EDITOR "$HOME/.config/pass-tomb/config"
```

Example config:

```sh
PASS_TOMB_FILE="$HOME/Vaults/passwords.tomb"
PASS_TOMB_KEY="$HOME/Vaults/passwords.tomb.key"
PASS_TOMB_BRANCH=main
```

## Create the Tomb

Skip this section if the Tomb already exists.

```sh
pass-tomb create-tomb 256
export PASS_TOMB_KEY="$HOME/Vaults/passwords.tomb.key"
pass-tomb open
```

## Create or import the pass GPG key

Open an isolated shell that uses the GPG home inside the Tomb:

```sh
pass-tomb shell
```

Generate a dedicated pass key:

```sh
pass-tomb keygen "Jagteshver Singh <85994817+JS-CodeGamer@users.noreply.github.com>"
```

Or import an existing private key:

```sh
pass-tomb import-key /path/to/private-key.asc
```

Copy the full fingerprint from:

```sh
gpg --list-secret-keys --keyid-format LONG
```

## Create the GitHub repo

Because the current `gh` auth token is invalid, refresh it first:

```sh
gh auth refresh -h github.com
```

Then create an empty private repo:

```sh
gh repo create pass-store --private
```

Use the SSH remote shown by GitHub, usually:

```sh
git@github.com:JS-CodeGamer/pass-store.git
```

## Initialize pass on the first laptop

Run inside `pass-tomb shell`, replacing the fingerprint and remote:

```sh
pass-tomb init-pass FINGERPRINT git@github.com:JS-CodeGamer/pass-store.git
pass insert web/example
pass-tomb sync
pass-tomb close
```

If close says the Tomb is busy:

```sh
fuser -vm "$PASS_TOMB_MOUNT"
pass-tomb slam
```

For a command-only checklist:

```sh
pass-tomb bootstrap
```

## Daily use

```sh
pass-tomb open
eval "$(pass-tomb env)"
pass-tomb sync
pass show web/example
pass insert web/new-login
pass-tomb sync
pass-tomb close
```

Use `pass-tomb shell` instead of `eval "$(pass-tomb env)"` if you prefer a dedicated shell that already has `GNUPGHOME` and `PASSWORD_STORE_DIR` set.

## Add another laptop

1. Install the packages and dotfiles.
2. Copy or sync the Tomb file and Tomb key through your non-GitHub backup path.
3. Open the Tomb:

```sh
export PASS_TOMB_KEY="$HOME/Vaults/passwords.tomb.key"
pass-tomb open
pass-tomb shell
```

4. Clone the private repo into the Tomb:

```sh
pass-tomb clone git@github.com:JS-CodeGamer/pass-store.git
pass-tomb status
pass show web/example
```

## Rotation and recovery

- Keep an offline backup of the Tomb file and Tomb key.
- Keep a revoked/certified copy of the public GPG key somewhere outside the Tomb.
- Consider generating a revocation certificate after key creation:

```sh
gpg --output "$PASS_TOMB_MOUNT/pass-key-revocation.asc" --gen-revoke FINGERPRINT
```

- If you add a second recipient key later, run:

```sh
pass init FINGERPRINT_1 FINGERPRINT_2
pass git push
```
