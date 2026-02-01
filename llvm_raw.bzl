load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# LLVM fork with Bazel overlay fixes (macOS Python linkopts, zlib-ng warning suppression).
# Branch: nico-bazel at https://github.com/nicolasvasilache/llvm-project
LLVM_COMMIT = "719086eb052f8da78167ff55fdf794c2e5e23b8a"
LLVM_ARCHIVE_URL = "https://github.com/nicolasvasilache/llvm-project/archive/{commit}.tar.gz".format(commit = LLVM_COMMIT)
LLVM_ARCHIVE_PREFIX = "llvm-project-{commit}".format(commit = LLVM_COMMIT)

def _llvm_raw_impl(mctx):
    http_archive(
        name = "llvm-raw",
        build_file_content = "# EMPTY",
        sha256 = "",
        strip_prefix = LLVM_ARCHIVE_PREFIX,
        urls = [LLVM_ARCHIVE_URL],
    )

    # Runtime library repos for cross-compilation toolchains.
    # Uses the same archive URL (Bazel caches the download) with subdirectory strip prefixes.
    for lib in ["compiler-rt", "libcxx", "libcxxabi", "libunwind"]:
        http_archive(
            name = lib,
            build_file = Label("//third_party/llvm-project/20.x/{lib}:BUILD.tpl".format(lib = lib)),
            sha256 = "",
            strip_prefix = LLVM_ARCHIVE_PREFIX + "/" + lib,
            urls = [LLVM_ARCHIVE_URL],
        )

    http_archive(
        name = "llvm_zlib",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zlib-ng.BUILD",
        sha256 = "e36bb346c00472a1f9ff2a0a4643e590a254be6379da7cddd9daeb9a7f296731",
        strip_prefix = "zlib-ng-2.0.7",
        urls = ["https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.0.7.zip"],
    )

    http_archive(
        name = "llvm_zstd",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zstd.BUILD",
        sha256 = "7c42d56fac126929a6a85dbc73ff1db2411d04f104fae9bdea51305663a83fd0",
        strip_prefix = "zstd-1.5.2",
        urls = ["https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz"],
    )

    # http_archive(
    #     name = "vulkan_headers",
    #     build_file = "@llvm-raw//utils/bazel/third_party_build:vulkan_headers.BUILD",
    #     sha256 = "19f491784ef0bc73caff877d11c96a48b946b5a1c805079d9006e3fbaa5c1895",
    #     strip_prefix = "Vulkan-Headers-9bd3f561bcee3f01d22912de10bb07ce4e23d378",
    #     urls = ["https://github.com/KhronosGroup/Vulkan-Headers/archive/9bd3f561bcee3f01d22912de10bb07ce4e23d378.tar.gz"],
    # )

    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

llvm_raw = module_extension(
    implementation = _llvm_raw_impl,
)
