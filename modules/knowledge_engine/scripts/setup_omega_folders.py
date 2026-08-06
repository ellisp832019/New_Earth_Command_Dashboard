from common import ensure_dir, load_config, output_paths


def main() -> None:
    config = load_config()
    paths = output_paths(config)

    ensure_dir(paths["root"])

    for folder_name in config["scan_folders"]:
        ensure_dir(paths["root"] / folder_name)

    for folder in [
        paths["catalogue"],
        paths["indexing"],
        paths["audio"],
        paths["extracted_text"],
        paths["chunks"],
        paths["search_index"],
    ]:
        ensure_dir(folder)
        print(f"OK: {folder}")

    for name in [
        "Books",
        "Magazines",
        "Research_Papers",
        "Whitepapers",
        "Courses",
        "Reference_Material",
        "Import_Queue",
        "Archive",
    ]:
        ensure_dir(paths["audio"] / name)

    print("Omega OS Knowledge Engine folders are ready.")


if __name__ == "__main__":
    main()
