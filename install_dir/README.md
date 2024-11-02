# Mon Super Archiver

Alexandre HERSSENS
Arthur FOULON
Etan DUCOURTY

Mon Super Archiver est un ensemble de modules Bash permettant d'archiver, télécharger, extraire et uploader des fichiers. 

Chaque module peut être utilisé indépendemment.

Les fichiers sont uploadés sur [`file.io`](https://www.file.io/) et la clef est configurable dans le fichier [`file.io.key`](./sources/file.io.key).

Le webhook pour l'upload sur discord est éditable dans le fichier [`config.sh`](./sources/config.sh). La plupart des préférences peut aussi être éditée dans ce ficher ( nom de l'archive, fichier d'historique).

## Fichier `.tocompress`

Le fichier `.tocompress` est utilisé pour spécifier les fichiers et répertoires à inclure dans l'archive. Ce fichier est placé lors de l'installation dans le répertoire d'installation du programme `/bin/mon_super_archiver`.

L'emplacement du fichier peut être édité dans le fichier `config.sh` : `TO_COMPRESS_FILE`.

**Attention** Chaque ligne doit se terminer avec un retour à la ligne sinon elle ne sera pas lue.


## Dépendances

Ce programme a besoin des élements suivants pour fonctionner:
- bash
- curl ( téléchargé via apt-get dans l'installateur )

## Installation

**Format des fichiers** Les fichiers ont parfois été édités depuis Windows. Il peut être utile d'uliser `dos2unix` sur ces derniers pour s'assurer de leur bonne interprétation.

Le script d'installation est conçu pour fonctionner sur des systèmes Unix. Il peut ne pas fonctionner correctement sur Windows sans un environnement compatible (comme WSL).

Pour que le service puisse correctement être configuré, `systemd` doit être démarré sur la machine, ce n'est pas le cas avec WSL.

Assurez-vous que les chemins spécifiés dans les scripts sont corrects et accessibles.
Le script nécessite des privilèges sudo pour copier des fichiers dans des répertoires système et installer des dépendances.

Pour installer le projet, exécutez le script `installer.sh` :

```sh
sudo installer.sh
```

## Utilisation du programme
```sh
main.sh [options]
```
#### Options:

- `-a, --archive` : Archive les fichiers spécifiés dans `./.tocompress`.
- `-d, --download [date]` : Télécharge la dernière archive uploadée ou celle de la date spécifiée.
- `-e, --extract` : Extrait les fichiers de l'archive.
- `-u, --upload` : Uploade les fichiers archivés après archivage.
- `-s, --discord` : Uploade les fichiers archivés sur Discord.
- `-f, --force` : Force l'upload même si l'archive est identique à la dernière.
- `-h, --help` : Affiche le message d'aide.



## Structure du projet

### `/sources`
Ensemble des scripts bash

#### Script `archiver.sh`

Le script `archiver.sh` permet d'archiver les fichiers d'un répertoire spécifié en les encodant en base64 et en les stockant dans un fichier d'archive.

#### Utilisation:

```sh
archiver.sh <dir> <archive>
```

-  `<dir>` : Le répertoire contenant les fichiers à archiver.
- `<archive>` : Le fichier d'archive où les fichiers encodés seront stockés.

#### Fonctionnement:

Le script lit les fichiers du répertoire spécifié.
Chaque fichier est encodé en base64.
Les informations sur le fichier (nom et taille) ainsi que son contenu encodé sont ajoutés au fichier d'archive.

#### Options
- -h, --help : Affiche le message d'aide.


#### Script `extracter.sh`

Le script `extracter.sh` permet d'extraire les fichiers d'un fichier d'archive en les décodant depuis le format base64 et en les restaurant dans un répertoire spécifié.

#### Utilisation:

```sh
extracter.sh <archive> <output>
```

- `<archive>` : Le fichier d'archive contenant les fichiers encodés.
- `<output>` : Le répertoire où les fichiers décodés seront restaurés.

#### Fonctionnement:
Le script lit le fichier d'archive spécifié.
Chaque fichier encodé en base64 est décodé.
Les informations sur le fichier (nom et taille) ainsi que son contenu décodé sont utilisés pour restaurer les fichiers dans le répertoire de sortie.

#### Options
- -h, --help : Affiche le message d'aide.

#### Script `uploader.sh`

Le script `uploader.sh` permet d'uploader un fichier d'archive vers un service de stockage en ligne.

#### Utilisation:

```sh
uploader.sh <archive>
```

- `<archive>` : Le fichier d'archive à uploader.

#### Fonctionnement:

- Le script lit le fichier d'archive spécifié.
- Le fichier est uploadé vers un service de stockage en ligne en utilisant une clé API.

#### Options

- `-h, --help` : Affiche le message d'aide.

#### Script `downloader.sh`

Le script `downloader.sh` permet de télécharger un fichier d'archive depuis un service de stockage en ligne.

#### Utilisation:

downloader.sh <archive_url> <output>

- `<archive_url>` : L'URL du fichier d'archive à télécharger.
- `<output>` : Le répertoire où le fichier téléchargé sera stocké.

#### Fonctionnement:

- Le script télécharge le fichier d'archive depuis l'URL spécifiée.
- Le fichier téléchargé est stocké dans le répertoire de sortie spécifié.
- Le fichier est ensuite re-uploadé car file.io dans sa version gratuite n'autorise qu'un unique téléchargement par fichier.

#### Options

- `-h, --help` : Affiche le message d'aide.


#### Script `discord.sh`

Le script `discord.sh` permet d'uploader un fichier d'archive sur un serveur Discord via un webhook.

Remarque, les liens de téléchargement renvoyés par l'API Discord expirent après 24h. Passé cette date, il faut récupérer le fichier uploadé manuellement depuis le serveur Discord.

#### Utilisation:

```sh
discord.sh <archive>
```

- `<archive>` : Le fichier d'archive à uploader.

#### Fonctionnement:

- Le script lit le fichier d'archive spécifié.
- Le fichier est uploadé sur un serveur Discord en utilisant un webhook.

#### Options

- `-h, --help` : Affiche le message d'aide.


