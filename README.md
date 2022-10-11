Lien github

https://github.com/alexcesi/exam-react

## Créer le projet 
npx create-react-app <nom du projet>
## Github actions générer le main.yml de base
L'intégration continue a été mise en place avec github action.
Dans votre repo, allez dans l'onglet Actions et cliquez sur "set up a workflow yourself".
Un fichier yml est généré. Vous pouvez soit le modifier maintenant soit cliquer sur "start commit" et le modifier par la suite dans votre éditeur de code
Ne pas oublier de faire un git pull pour récuperer le fichier.

## Modifier le .yml pour votre CI CD
### Nommer votre ci cd 
name: <NOM>
### Configurer la CI pour qu'elle se déclenche lors de chaque push sur une branche (ici master)
on:
  push:
    branches: [ <Nom de votre branche par défaut: master> ]

### Build votre projet react sur un ubuntu et installe les dépendances
jobs:
  build-react:
    runs-on: ubuntu-latest
    steps:
      - name: Clone repository
        uses: actions/checkout@v2
      - name: Use Node.js 16.x
        uses: actions/setup-node@v1
        with:
          node-version: 16.x
      - name: Install dependencies
        run: npm install
      - name: Build Artefact 
        run: npm run build

### Executer les tests par défaut de votre projet
  test-react:
    runs-on: ubuntu-latest
    steps:
      - name: Clone repository
        uses: actions/checkout@v2
      - name: Use Node.js 16.x
        uses: actions/setup-node@v1
        with:
          node-version: 16.x
      - name: Install dependencies
        run: npm install
      - name: Run test 
        run: npm run test

### variables secret
Dans votre repo github, allez dans settings -> Secrets -> Actions
Cliquez sur New repository secret et ajouter vos variables d'environnements 
### Ajout de la variable ssh privée
      - name: Adding Known Hosts
        run: ssh-keyscan -H ${{ secrets.SSH_HOST }} >> ~/.ssh/known_hosts

### On copie dans dossier build avec rsync en ssh avec notre login du serveur distant et l'ip de ce serveur dans le dossier /web/build
      - name: Deploy with rsync
        run: rsync -avz ./build/ ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }}:~/web/build

### Versionning
Pour ajouter une version à vos différents builds :
      - name: Rename folder
        run: ssh ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} 'mv ~/web/build ~/web/build-$(date +%Y%m%d_%H%M%S)'


## Fichier Dockerfile
Tout d'abord il faut créer un fichier Dockerfile à la source de votre projet
### Cette instruction permet de spécifier le répertoire de travail dans lequel seront donc copiés des fichiers/dossiers dans les instructions suivantes.
WORKDIR /app

### L'instruction COPY permet de copier des fichiers/dossiers depuis le contexte de construction (depuis la machine hôte) vers le conteneur:
COPY package.json .
COPY package-lock.json .

### L'instruction RUN permet l'exécution de commandes depuis le conteneur.
RUN docker-php-ext-install pdo pdo_mysql
RUN npm install

### Copie ce qui se trouve à la base de notre dossier et le colle à la base de notre conteneur.
COPY . .

### Execute les 2 commandes dans le conteneur. Le build en production et l'installation de serve dans le conteneur
RUN npm run build --production
RUN npm install -g serve

### L'instruction CMD définit la commande que votre conteneur va utiliser
CMD [ "serve", "-s", "build" ]

## Informations complémentaires:
Une fois le conteneur lancé, vous pouvez accéder à votre application en changeant "http://localhost:3000" par "http://localhost:3001" (le port du conteneur)