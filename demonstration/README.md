# Essais réalisés

## Installation
```bash
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ sudo ./install_dir/installer.sh > install.log 2>&1
```
```bash
# Ajout d'un dossier à archiver
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ echo /mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX/install_dir/sources > /bin/mon_super_archiver/.tocompress 
```

## Fonctionnalités

### [Archive simple](./archive.log) 
```bash
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ /bin/mon_super_archiver/main.sh -a > archive.log  2>&1
```

### [Désarchivage simple](./archive.log) 
```bash
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ /bin/mon_super_archiver/main.sh -e > extract.log  2>&1
```

### [Archivage + Upload file.io + Upload Discord ](./archive.log) 
```bash
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ /bin/mon_super_archiver/main.sh -u --discord > upload.log  2>&1
```

### [Téléchargement depuis file.io + Désarchivage](./archive.log) 
```bash
alex@Alex-DESKTOP:/mnt/c/Users/alex/OneDrive/Bureau/AP4_LINUX$ /bin/mon_super_archiver/main.sh -d > download.log  2>&1
```