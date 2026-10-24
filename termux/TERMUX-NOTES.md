# Memos di Termux — catatan port

- Upstream: https://github.com/usememos/memos — versi yang di-port: **v0.31.0** (Go 1.27, SQLite default via modernc.org/sqlite pure-Go, frontend React tertanam via go:embed).
- Binary resmi `memos_0.31.0_linux_arm64.tar.gz` = statis **ET_EXEC** → ditolak linker Android ("unexpected e_type: 2"). Wajib build ulang.
- Resep build: `GOOS=android GOARCH=arm64 CGO_ENABLED=1` + CC clang NDK r28c (`aarch64-linux-android24-clang`), flag upstream dipertahankan: `-trimpath -tags netgo,osusergo`, ldflags stempel `internal/version.Version`/`Commit`, TANPA `-extldflags '-static'`.
- Hasil wajib: Type DYN, AArch64, INTERP /system/bin/linker64, NEEDED hanya bionic (gate readelf di CI + verifikasi unduh).
- Frontend dibangun di CI: `pnpm install --frozen-lockfile` di web/ lalu `pnpm release` (vite build → server/frontend/dist).
- Runtime: `memos --data ~/.memos --port 8081` (port default versi ini 8081; driver default sqlite).
- Status: RELEASE **v0.31.0-termux.2** LIVE (CI run 40061289343, semua step hijau) — aset terverifikasi unduh: sha256 3fc7e553…, ELF DYN/AArch64/linker64. MENUNGGU uji perangkat ulang user.
- TEMUAN PERANGKAT (.1, 2026-10-24): binary valid tapi Cobra menolak semua perintah: `unknown command "/data/data/com.termux/files/usr/bin/memos"` — linker64 Android menduplikasi path executable sebagai argv[1]. Diperbaiki di .2 oleh `termux/android-argv-fix.patch` (main() membuang argv[1] bila sama dengan os.Executable(); terbukti via simulasi execv argv-duplikat di binary amd64: tanpa patch error identik, dengan patch server boot + HTTP 200).
