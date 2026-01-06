#!/usr/bin/env python3
"""
Script de conversion Markdown (Obsidian) vers Neorg
Convertit les fichiers .md avec YAML frontmatter vers .norg avec @document.meta
"""

import re
import os
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple


class MarkdownToNeorgConverter:
    def __init__(self, notes_dir: str = "~/.sync/notes"):
        self.notes_dir = Path(notes_dir).expanduser()
        self.mapping = {}  # Mapping ancien chemin -> nouveau chemin

    def parse_yaml_frontmatter(self, content: str) -> Tuple[Dict, str]:
        """Extrait le YAML frontmatter et retourne (metadata, content_sans_yaml)"""
        if not content.startswith("---"):
            return {}, content

        # Trouver le deuxième ---
        match = re.match(r"^---\n(.*?)\n---\n(.*)$", content, re.DOTALL)
        if not match:
            return {}, content

        yaml_content = match.group(1)
        remaining_content = match.group(2)

        try:
            metadata = yaml.safe_load(yaml_content) or {}
        except yaml.YAMLError:
            metadata = {}

        return metadata, remaining_content

    def extract_title_from_filename(self, filename: str) -> str:
        """Extrait le titre depuis le nom de fichier"""
        # Retire l'extension .md
        name = filename.replace(".md", "")

        # Retire le timestamp si présent (format: 202XXXXXXXXXXX - Title)
        match = re.match(r"^\d{12,14}\s*-\s*(.+)$", name)
        if match:
            return match.group(1)

        # Retire les préfixes type "00 - Index"
        match = re.match(r"^\d+\s*-\s*(.+)$", name)
        if match:
            return match.group(1)

        return name

    def create_norg_filename(self, original_name: str) -> str:
        """Crée le nom de fichier .norg en kebab-case"""
        # Extraire le titre
        title = self.extract_title_from_filename(original_name)

        # Convertir en kebab-case
        kebab = title.lower()
        kebab = re.sub(r"[àáâãäå]", "a", kebab)
        kebab = re.sub(r"[èéêë]", "e", kebab)
        kebab = re.sub(r"[ìíîï]", "i", kebab)
        kebab = re.sub(r"[òóôõö]", "o", kebab)
        kebab = re.sub(r"[ùúûü]", "u", kebab)
        kebab = re.sub(r"[ç]", "c", kebab)
        kebab = re.sub(r"['\"]", "", kebab)
        kebab = re.sub(r"[^a-z0-9]+", "-", kebab)
        kebab = kebab.strip("-")

        return f"{kebab}.norg"

    def yaml_to_norg_meta(self, metadata: Dict, title: str) -> str:
        """Convertit le YAML frontmatter en @document.meta neorg"""
        # Extraire la date de création
        date_str = metadata.get("date", "")
        if date_str:
            try:
                if isinstance(date_str, str):
                    # Format: 2024-04-14T18:06
                    created = date_str.split("T")[0]
                else:
                    created = str(date_str).split("T")[0]
            except:
                created = datetime.now().strftime("%Y-%m-%d")
        else:
            created = datetime.now().strftime("%Y-%m-%d")

        # Extraire les tags
        tags = metadata.get("tags", [])
        if isinstance(tags, list):
            tags = [tag.lower().replace(" ", "-") for tag in tags]
        else:
            tags = []

        # Créer les catégories
        categories_str = "\n".join([f"  {tag}" for tag in tags]) if tags else ""

        meta = f"""@document.meta
title: {title}
description:
authors: codebarre
categories: [
{categories_str}
]
created: {created}
updated: {datetime.now().strftime("%Y-%m-%d")}
version: 1.1.1
@end
"""
        return meta

    def convert_headings(self, content: str) -> str:
        """Convertit les headings Markdown (#) en Neorg (*)"""
        lines = content.split("\n")
        converted = []

        for line in lines:
            # Compter les # au début
            match = re.match(r"^(#{1,6})\s+(.+)$", line)
            if match:
                level = len(match.group(1))
                title = match.group(2)
                converted.append("*" * level + " " + title)
            else:
                converted.append(line)

        return "\n".join(converted)

    def convert_wiki_links(self, content: str) -> str:
        """Convertit les wiki-links [[]] en liens neorg {:}[]"""
        # Format: [[202502081202 - Icarus|Icarus]] -> {:/icarus:}[Icarus]
        # Format: [[file]] -> {:/file:}

        def replace_link(match):
            full_link = match.group(1)

            # Avec alias: [[link|alias]]
            if "|" in full_link:
                link, alias = full_link.split("|", 1)
                link = link.strip()
                alias = alias.strip()
            else:
                link = full_link.strip()
                alias = link

            # Extraire le titre du lien (retirer timestamp)
            link_title = self.extract_title_from_filename(link)
            link_kebab = self.create_norg_filename(link_title).replace(".norg", "")

            return f"{{:/{link_kebab}:}}[{alias}]"

        # Remplacer tous les [[...]]
        content = re.sub(r"\[\[([^\]]+)\]\]", replace_link, content)

        return content

    def convert_markdown_links(self, content: str) -> str:
        """Convertit les liens Markdown [text](url) en liens neorg {url}[text]"""
        # Format: [text](url) -> {url}[text]
        content = re.sub(r"\[([^\]]+)\]\(([^\)]+)\)", r"{\2}[\1]", content)
        return content

    def convert_blockquotes(self, content: str) -> str:
        """Convertit les blockquotes > en listes indentées (optionnel)"""
        # Pour l'instant, on garde les > tels quels
        # Neorg supporte les quotes avec >
        return content

    def convert_lists(self, content: str) -> str:
        """Ajuste les listes si nécessaire"""
        # Neorg utilise aussi - pour les listes
        # Les tâches: - [ ] -> - ( )
        content = re.sub(r"^(\s*)-\s+\[\s\]\s+", r"\1- ( ) ", content, flags=re.MULTILINE)
        content = re.sub(r"^(\s*)-\s+\[x\]\s+", r"\1- (x) ", content, flags=re.MULTILINE)
        content = re.sub(r"^(\s*)-\s+\[X\]\s+", r"\1- (x) ", content, flags=re.MULTILINE)
        return content

    def convert_content(self, content: str) -> str:
        """Applique toutes les conversions de contenu"""
        content = self.convert_headings(content)
        content = self.convert_wiki_links(content)
        content = self.convert_markdown_links(content)
        content = self.convert_blockquotes(content)
        content = self.convert_lists(content)
        return content

    def convert_file(self, md_path: Path) -> Tuple[str, str]:
        """
        Convertit un fichier .md en .norg
        Retourne (nouveau_chemin, contenu_norg)
        """
        # Lire le fichier
        with open(md_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Parser le frontmatter
        metadata, content_body = self.parse_yaml_frontmatter(content)

        # Extraire le titre
        title = self.extract_title_from_filename(md_path.name)

        # Créer le metadata neorg
        norg_meta = self.yaml_to_norg_meta(metadata, title)

        # Convertir le contenu
        norg_content = self.convert_content(content_body)

        # Combiner
        full_norg = norg_meta + "\n" + norg_content

        # Déterminer le nouveau chemin
        new_filename = self.create_norg_filename(md_path.name)

        return new_filename, full_norg

    def get_new_path(self, old_path: Path) -> Path:
        """Détermine le nouveau chemin PARA pour un fichier"""
        # Extraire la catégorie depuis le chemin
        parts = old_path.relative_to(self.notes_dir).parts

        # Mapper les anciens dossiers vers les nouveaux
        category_map = {
            "01 - Projects": "projects",
            "02 - Areas": "areas",
            "03 - Resources": "resources",
            "04 - Permanent Notes": "resources",  # Fusionné dans resources
            "05 - Archives": "archives",
        }

        if len(parts) > 0 and parts[0] in category_map:
            new_category = category_map[parts[0]]
            # Recréer le chemin avec les sous-dossiers
            sub_path = Path(*parts[1:-1]) if len(parts) > 2 else Path()
            return self.notes_dir / new_category / sub_path

        # Si pas de catégorie reconnue, mettre dans resources
        return self.notes_dir / "resources"

    def convert_all(self, dry_run: bool = True):
        """Convertit tous les fichiers .md en .norg"""
        md_files = list(self.notes_dir.rglob("*.md"))

        print(f"🔍 Trouvé {len(md_files)} fichiers Markdown\n")

        for md_path in md_files:
            try:
                # Ignorer les fichiers dans meta/ ou 99 - Meta/
                if "meta" in str(md_path).lower() or "99 - meta" in str(md_path).lower():
                    continue

                # Convertir
                new_filename, norg_content = self.convert_file(md_path)
                new_dir = self.get_new_path(md_path)
                new_path = new_dir / new_filename

                # Afficher
                rel_old = md_path.relative_to(self.notes_dir)
                rel_new = new_path.relative_to(self.notes_dir)
                print(f"📄 {rel_old}")
                print(f"   ➜ {rel_new}")

                if not dry_run:
                    # Créer le dossier si nécessaire
                    new_path.parent.mkdir(parents=True, exist_ok=True)

                    # Écrire le fichier
                    with open(new_path, "w", encoding="utf-8") as f:
                        f.write(norg_content)

                    print(f"   ✅ Converti\n")
                else:
                    print(f"   🔸 Dry run - pas de modification\n")

                # Sauvegarder le mapping
                self.mapping[str(rel_old)] = str(rel_new)

            except Exception as e:
                print(f"❌ Erreur avec {md_path.name}: {e}\n")


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Convertir Markdown vers Neorg")
    parser.add_argument("--dry-run", action="store_true", help="Simulation sans écriture")
    parser.add_argument("--file", type=str, help="Convertir un seul fichier (test)")
    parser.add_argument("--notes-dir", type=str, default="~/.sync/notes", help="Dossier des notes")
    parser.add_argument("-y", "--yes", action="store_true", help="Ne pas demander de confirmation")

    args = parser.parse_args()

    converter = MarkdownToNeorgConverter(args.notes_dir)

    if args.file:
        # Mode test sur un seul fichier
        md_path = Path(args.file).expanduser()
        if not md_path.exists():
            print(f"❌ Fichier introuvable: {md_path}")
            return

        print("🧪 Mode test - Conversion d'un seul fichier\n")
        new_filename, norg_content = converter.convert_file(md_path)

        print(f"📄 Fichier original: {md_path.name}")
        print(f"📝 Nouveau nom: {new_filename}")
        print(f"\n{'='*80}")
        print("CONTENU CONVERTI:")
        print('='*80)
        print(norg_content)
        print('='*80)
    else:
        # Mode conversion complète
        if args.dry_run:
            print("🔸 MODE DRY RUN - Aucune modification ne sera faite\n")
        else:
            print("⚠️  MODE ÉCRITURE - Les fichiers seront créés\n")
            if not args.yes:
                response = input("Continuer? (y/N): ")
                if response.lower() != "y":
                    print("Annulé.")
                    return

        converter.convert_all(dry_run=args.dry_run)

        print(f"\n✅ Terminé! {len(converter.mapping)} fichiers traités.")


if __name__ == "__main__":
    main()
