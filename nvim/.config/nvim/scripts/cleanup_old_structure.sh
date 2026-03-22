#!/bin/bash
#
# Script de nettoyage après migration Markdown → Neorg
# Ce script:
# 1. Crée un backup des fichiers .md
# 2. Supprime les fichiers .md et anciens dossiers
# 3. Fusionne les dossiers en double (majuscules/minuscules)
#

set -e

NOTES_DIR="$HOME/.sync/notes"
BACKUP_DIR="$HOME/.sync/notes-backup-$(date +%Y%m%d-%H%M%S)"

echo "🧹 Nettoyage de l'ancienne structure Markdown"
echo ""

# Demander confirmation (sauf si -y est passé)
if [[ "$1" != "-y" ]]; then
    read -p "⚠️  Ce script va supprimer les fichiers .md et anciens dossiers. Continuer? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Annulé."
        exit 1
    fi
fi

# Étape 1: Créer un backup
echo "📦 Création du backup dans: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Copier tous les fichiers .md
find "$NOTES_DIR" -name "*.md" -type f -exec cp --parents {} "$BACKUP_DIR" \;

# Copier les anciens dossiers
for dir in "00 - Maps of Content" "01 - Projects" "02 - Areas" "03 - Resources" "04 - Permanent" "05 - Archives" "99 - Meta"; do
    if [ -d "$NOTES_DIR/$dir" ]; then
        cp -r "$NOTES_DIR/$dir" "$BACKUP_DIR/"
    fi
done

echo "✅ Backup créé: $BACKUP_DIR"
echo ""

# Étape 2: Supprimer les fichiers .md
echo "🗑️  Suppression des fichiers .md..."
find "$NOTES_DIR" -name "*.md" -type f -delete
echo "✅ Fichiers .md supprimés"
echo ""

# Étape 3: Fusionner les dossiers en double (majuscules → minuscules)
echo "🔀 Fusion des dossiers en double..."

# Projects
if [ -d "$NOTES_DIR/projects/Computer Science" ]; then
    if [ ! -d "$NOTES_DIR/projects/computer-science" ]; then
        mkdir -p "$NOTES_DIR/projects/computer-science"
    fi
    mv "$NOTES_DIR/projects/Computer Science"/* "$NOTES_DIR/projects/computer-science/" 2>/dev/null || true
    rmdir "$NOTES_DIR/projects/Computer Science" 2>/dev/null || true
fi

if [ -d "$NOTES_DIR/projects/YT" ]; then
    if [ ! -d "$NOTES_DIR/projects/youtube" ]; then
        mkdir -p "$NOTES_DIR/projects/youtube"
    fi
    mv "$NOTES_DIR/projects/YT"/* "$NOTES_DIR/projects/youtube/" 2>/dev/null || true
    rmdir "$NOTES_DIR/projects/YT" 2>/dev/null || true
fi

# Areas
if [ -d "$NOTES_DIR/areas/Maldev" ]; then
    if [ ! -d "$NOTES_DIR/areas/maldev" ]; then
        mkdir -p "$NOTES_DIR/areas/maldev"
    fi
    mv "$NOTES_DIR/areas/Maldev"/* "$NOTES_DIR/areas/maldev/" 2>/dev/null || true
    rmdir "$NOTES_DIR/areas/Maldev" 2>/dev/null || true
fi

if [ -d "$NOTES_DIR/areas/Blog" ]; then
    if [ ! -d "$NOTES_DIR/areas/blog" ]; then
        mkdir -p "$NOTES_DIR/areas/blog"
    fi
    mv "$NOTES_DIR/areas/Blog"/* "$NOTES_DIR/areas/blog/" 2>/dev/null || true
    rmdir "$NOTES_DIR/areas/Blog" 2>/dev/null || true
fi

if [ -d "$NOTES_DIR/areas/CH" ]; then
    if [ ! -d "$NOTES_DIR/areas/ch" ]; then
        mkdir -p "$NOTES_DIR/areas/ch"
    fi
    mv "$NOTES_DIR/areas/CH"/* "$NOTES_DIR/areas/ch/" 2>/dev/null || true
    rmdir "$NOTES_DIR/areas/CH" 2>/dev/null || true
fi

# Resources
if [ -d "$NOTES_DIR/resources/Books" ]; then
    if [ ! -d "$NOTES_DIR/resources/books" ]; then
        mkdir -p "$NOTES_DIR/resources/books"
    fi
    mv "$NOTES_DIR/resources/Books"/* "$NOTES_DIR/resources/books/" 2>/dev/null || true
    rmdir "$NOTES_DIR/resources/Books" 2>/dev/null || true
fi

if [ -d "$NOTES_DIR/resources/Podcasts" ]; then
    if [ ! -d "$NOTES_DIR/resources/podcasts" ]; then
        mkdir -p "$NOTES_DIR/resources/podcasts"
    fi
    mv "$NOTES_DIR/resources/Podcasts"/* "$NOTES_DIR/resources/podcasts/" 2>/dev/null || true
    rmdir "$NOTES_DIR/resources/Podcasts" 2>/dev/null || true
fi

if [ -d "$NOTES_DIR/resources/YT Videos" ]; then
    if [ ! -d "$NOTES_DIR/resources/videos" ]; then
        mkdir -p "$NOTES_DIR/resources/videos"
    fi
    mv "$NOTES_DIR/resources/YT Videos"/* "$NOTES_DIR/resources/videos/" 2>/dev/null || true
    rmdir "$NOTES_DIR/resources/YT Videos" 2>/dev/null || true
fi

echo "✅ Dossiers fusionnés"
echo ""

# Étape 4: Supprimer les anciens dossiers
echo "🗑️  Suppression des anciens dossiers..."

for dir in "00 - Maps of Content" "01 - Projects" "02 - Areas" "03 - Resources" "04 - Permanent" "05 - Archives" "99 - Meta"; do
    if [ -d "$NOTES_DIR/$dir" ]; then
        rm -rf "$NOTES_DIR/$dir"
        echo "  ✓ Supprimé: $dir"
    fi
done

echo "✅ Anciens dossiers supprimés"
echo ""

# Résumé final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Migration terminée avec succès!"
echo ""
echo "📂 Structure actuelle:"
tree -L 1 "$NOTES_DIR" -I 'venv|*.pyc|.git'
echo ""
echo "💾 Backup conservé dans: $BACKUP_DIR"
echo "   (Vous pouvez le supprimer manuellement une fois que tout fonctionne)"
echo ""
echo "🎉 Votre système PARA est maintenant prêt!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
