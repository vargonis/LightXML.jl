using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libxml2"], :libxml2),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/bicycle1885/XML2Builder/releases/download/v1.0.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/XML2Builder.v2.9.9.aarch64-linux-gnu.tar.gz", "babc5bd8e29db21ad75b15f1593188d5c1861d910e7ada1362a79770d20d1317"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/XML2Builder.v2.9.9.aarch64-linux-musl.tar.gz", "e8aa6fc5210e50ea8bec65f8bc2773ff2f860780fa54aece14a26e982b12d415"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/XML2Builder.v2.9.9.arm-linux-gnueabihf.tar.gz", "03ca6f10afdee662b7a0a3ba56b470dfe2272dd5970a0b37d12965e34410bd13"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/XML2Builder.v2.9.9.arm-linux-musleabihf.tar.gz", "ac342909c78f734d658055c32155c4986b855a747b47e87f302991e4871070ff"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/XML2Builder.v2.9.9.i686-linux-gnu.tar.gz", "5585e4f7c737f8df5013f0da840490e1e37375d48bcb96b25a711e2524594700"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/XML2Builder.v2.9.9.i686-linux-musl.tar.gz", "0a56fec39c4a0674db8b3a31f7bfa572cff9f2fb4452e5e258451a9248eeae1f"),
    Windows(:i686) => ("$bin_prefix/XML2Builder.v2.9.9.i686-w64-mingw32.tar.gz", "1a64c106cdbba17fc4219bc0c3be9842e7a95a0e44462e532077848bdebc31f8"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/XML2Builder.v2.9.9.powerpc64le-linux-gnu.tar.gz", "2d293e202f1bd61ca2513389ed0f45a9daf922e0a8a4b0be69c680f37a5197b5"),
    MacOS(:x86_64) => ("$bin_prefix/XML2Builder.v2.9.9.x86_64-apple-darwin14.tar.gz", "230bfa17e6a263703b7ae81a49de5c30395bb5e9707e452b4e7f26a7306b823d"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/XML2Builder.v2.9.9.x86_64-linux-gnu.tar.gz", "d3e1917fc890d974b505c677506cd9bac36c40957f4307e61b2cb6b0ea86e8a8"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/XML2Builder.v2.9.9.x86_64-linux-musl.tar.gz", "b48de935490201570d470d4d1210b7f3a3ec57b788e7befe4cf93498cbb17b9f"),
    FreeBSD(:x86_64) => ("$bin_prefix/XML2Builder.v2.9.9.x86_64-unknown-freebsd11.1.tar.gz", "467bfcaf79fe488e4f6a8fc854f77f130885ffe0e8f890ed82f457dfef38deae"),
    Windows(:x86_64) => ("$bin_prefix/XML2Builder.v2.9.9.x86_64-w64-mingw32.tar.gz", "6f5620dfc9901545900705313217351720a792b18ef14af29ce18d2f5b0326f7"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
