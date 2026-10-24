# Memos di Termux — catatan port

- Upstream: https://github.com/usememos/memos — versi yang di-port: **v0.31.0** (Go 1.27, SQLite default via modernc.org/sqlite pure-Go, frontend React tertanam via go:embed).
- Binary resmi `memos_0.31.0_linux_arm64.tar.gz` = statis **ET_EXEC** → ditolak linker Android ("unexpected e_type: 2"). Wajib build ulang.
- Resep build: `GOOS=android GOARCH=arm64 CGO_ENABLED=1` + CC clang NDK r28c (`aarch64-linux-android24-clang`), flag upstream dipertahankan: `-trimpath -tags netgo,osusergo`, ldflags stempel `internal/version.Version`/`Commit`, TANPA `-extldflags '-static'`.
- Hasil wajib: Type DYN, AArch64, INTERP /system/bin/linker64, NEEDED hanya bionic (gate readelf di CI + verifikasi unduh).
- Frontend dibangun di CI: `pnpm install --frozen-lockfile` di web/ lalu `pnpm release` (vite build → server/frontend/dist).
- Runtime: `memos --data ~/.memos --port 8081` (port default versi ini 8081; driver default sqlite).
- Status: MENUNGGU proof build lokal + CI + uji perangkat user.
