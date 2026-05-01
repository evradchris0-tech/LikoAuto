# Liko Auto - UI/UX Design Specification Document

## 1. Design System & Global Styles

### 1.1. Couleurs (Color Palette)
* **Primaire (Primary) :** Bleu Nuit Profond (ex: `#0F203C`). Utilisé pour les en-têtes, les textes principaux, et les fonds de sections Premium.
* **Accent (Action/Primary Button) :** Orange Rouille/Terracotta (ex: `#D35400` ou `#E65100`). Utilisé pour les boutons d'action principaux (CTA), les notifications, et le bouton central de la barre de navigation.
* **Succès/Validation :** Vert Émeraude (ex: `#27AE60`). Utilisé pour les badges "VIN vérifié" et les statuts "Ouvert".
* **Fond (Background) :** Blanc pur `#FFFFFF` pour les cartes, et Gris très clair `#F8F9FA` pour les fonds d'écran.
* **Texte (Typography) :** Gris anthracite pour le texte principal, gris moyen pour le texte secondaire (descriptions, timestamps).

### 1.2. Typographie
* **Police :** Sans-serif moderne et géométrique (ex: Inter, Poppins ou Roboto).
* **Titres (H1/H2) :** Gras (Bold), fort contraste.
* **Corps de texte :** Régulier (Regular), très lisible.

### 1.3. Composants globaux
* **Boutons (Buttons) :** Coins arrondis (border-radius: 12px à 16px). Pleine largeur pour les CTA principaux en bas d'écran.
* **Cartes (Cards) :** Ombre portée très légère (soft drop shadow), coins arrondis (border-radius: 16px).
* **Bottom Navigation Bar (Barre de navigation inférieure) :** * Fond blanc, icônes grises (actives en Bleu ou Orange).
    * 5 éléments : Accueil, Rechercher, Vendre (Bouton d'action flottant central - FAB Orange avec icône '+'), Chat, Moi.

---

## 2. Écrans de Première Ouverture (Onboarding)
*Contexte : 4 écrans "swipeables" affichés au premier lancement. Fond blanc, éléments visuels en haut, texte et CTA en bas.*

### Écran 2.1 : Bienvenue (01 - Bienvenue)
* **Visuel (Haut) :** Grande image stylisée d'un Toyota Land Cruiser dans un paysage (moitié supérieure de l'écran). Sur l'image, des tags flottants : "VIN vérifié", "Douala".
* **Texte (Bas) :**
    * Sur-titre (Orange, petites majuscules) : "ÉTAPE 1 SUR 4".
    * Titre (H1, Bleu Nuit) : "Bienvenue sur Liko Auto."
    * Paragraphe : "La marketplace de voitures la plus fiable du Cameroun — de Douala à Yaoundé."
* **Statistiques (Superposées entre l'image et le texte) :** Une carte bleue nuit avec 3 stats : "187 VÉHICULES EN LIGNE", "92% VIN VÉRIFIÉS", "48 GARAGES".
* **Actions :** Bouton pleine largeur Orange "Continuer ->". Lien texte discret en dessous "Passer".

### Écran 2.2 : VIN Expliqué (02 - VIN Expliqué)
* **Visuel (Haut) :** Image d'un SUV (Toyota Hilux). En surimpression, un pointeur rouge indique le châssis avec un tooltip "JT1DE12E806123489" (Le numéro de série).
* **Texte (Bas) :**
    * Sur-titre : "ÉTAPE 2 SUR 4".
    * Titre : "La carte d'identité de votre véhicule."
    * Paragraphe : "Le numéro de série (VIN) est la CNI de votre voiture. 17 chiffres uniques, gravés une fois à l'usine. Chez Liko, il est vérifié automatiquement."
* **Liste à puces (HStack avec icônes check oranges) :**
    * Protège acheteurs et vendeurs
    * Révèle les duplicatas et fraudes
    * Un simple scan suffit
* **Actions :** Bouton Orange "Continuer".

### Écran 2.3 : Garages (03 - Garages)
* **Visuel (Haut) :** Une carte (Map) simplifiée du Cameroun avec des points (Douala, Yaoundé, Bafoussam) entourés d'une zone d'influence rouge/orange. Tags en dessous : "SPÉCIALISTES TOYOTA · MERCEDES · BMW".
* **Texte (Bas) :**
    * Sur-titre : "ÉTAPE 3 SUR 4".
    * Titre : "Trouvez le bon garage en un clic."
    * Paragraphe : "Spécialistes par marque et par quartier — Bonapriso, Akwa, Bastos. Prise de RDV directement via chat."
* **Bannière info :** Carte grise "48 garages certifiés. Vérifiés, notés, géolocalisés. (Étoile 4,7)".
* **Actions :** Bouton Orange "Continuer".

### Écran 2.4 : Chat (04 - Chat)
* **Visuel (Haut) :** Fausse interface de conversation de messagerie superposée. Bulles de chat entre l'utilisateur et "Garage Elite Auto". Une carte "RDV EXPERTISE" confirmée pour "Jeu. 4 avr • 10h00".
* **Texte (Bas) :**
    * Sur-titre : "ÉTAPE 4 SUR 4".
    * Titre : "Le chat qui remplace le téléphone."
    * Paragraphe : "Discutez, négociez, fixez un RDV — sans jamais partager votre numéro."
* **Actions :** Bouton Orange "Commencer ->". Lien texte en dessous "Déjà un compte ? Se connecter".

---

## 3. Écrans Principaux (Navigation Basse Active)

### 3.1. Accueil (Home - Variante Compacte recommandée)
* **Header :** * Barre de recherche "Rechercher..." avec icône loupe.
    * Icône cloche de notification (avec point rouge) à droite.
    * Boutons filtres rapides (HScroll) : "Tous" (actif, fond bleu), "VIN vérifié", "Moins 10M", "Toyota".
* **Bannière Promo (Hero) :** Image d'un SUV de profil avec texte superposé : "Vendez plus vite avec le badge VIN." et un bouton orange "Vendre en 2 min ->". Badge au-dessus : "+187 À DOUALA".
* **Section "Dernières annonces" :**
    * En-tête "Dernières annonces" avec bouton "Trier".
    * **Liste de cartes véhicules (VStack) :** Chaque carte est une rangée (HStack).
        * Image miniature à gauche (avec badge nb de photos).
        * Détails à droite : Titre ("Toyota RAV4 2020"), Prix ("14 500 000 FCFA", Orange, gras), Localisation ("Akwa, Douala • 42 000 km").
        * Badges : Tag vert "✓ VIN" et potentiellement tag orange "Pro".
        * Icône coeur (favori) en haut à droite de chaque carte.

### 3.2. Rechercher & Liste de résultats
* **Header :** Grand titre "Rechercher", bouton vue "Carte" (Map).
* **Barre de recherche :** Remplie avec "Toyota".
* **Filtres actifs (HScroll) :** "Filtres (3)", "Toyota (x)", "Douala (x)", "VIN vérifié (x)".
* **Résultats :** Texte "248 résultats à Douala" et menu déroulant "Récent v".
* **Liste :** Similaire à l'accueil, mais les images sont plus grandes.

### 3.3. Fiche Véhicule (Détail d'une annonce)
* **Image Header :** Grande image du véhicule (pleine largeur, swipeable). Bouton retour "<", favori "♡" et partage en haut (flottants sur l'image). Badge compteur d'images "1/22 • +vidéo".
* **En-tête info :**
    * Badges : Vert "✓ VIN vérifié", Orange "Vendeur Pro", "Négociable".
    * Titre : "Toyota Hilux Revo 2019"
    * Localisation : "📍 Bonapriso, Douala"
    * Prix : "18 900 000 FCFA - négociable" (Très grand, texte orange).
* **Caractéristiques (Grid 4 colonnes) :** Cartes carrées gris clair pour : Km (68 000), Carburant (Diesel), Boîte (Auto), Année (2019).
* **Description :** Titre "DESCRIPTION", texte descriptif.
* **Bottom Action Bar (Fixe en bas) :** Deux boutons. 
    * Gauche : Bouton blanc bordure grise avec icône téléphone "Appeler". 
    * Droite : Grand bouton Orange "Contacter via Chat".

### 3.4. Annuaire Garages & Fiche Garage
* **Annuaire :** * Header "Annuaire Garages", toggle Voitures/Garages.
    * Liste de cartes. Chaque carte : Image du garage, Nom ("Elite Auto"), Tag "Ouvert" (Vert), Localisation, Note ("⭐️ 4,8"), Marques ("Toyota, Lexus"). Bouton "Chat" sur la carte.
* **Fiche Garage :**
    * Image du garage en en-tête. Badge "Garage certifié" et statut "Ouvert - ferme 18h".
    * Nom "Elite Auto" et adresse exacte.
    * Stats : Note (4,8/5), Distance (2,1 km), Depuis (2014).
    * Liste des services (VStack) : "Expertise avant achat - 15 000 FCFA", "Diagnostic électronique - 8 000 FCFA", etc.
    * Bottom Action Bar : Bouton blanc "RDV" et bouton Orange "Contacter via Chat".

---

## 4. Messagerie & Profil

### 4.1. Chat - Liste des messages
* **Header :** Titre "Messages", badge "3 NON LUS". Filtres : Tous (actif), Voitures, Garages.
* **Liste de conversations :**
    * Avatar circulaire (photo de voiture ou garage). Badge vert si en ligne.
    * Nom de l'interlocuteur / Garage (ex: "Garage Elite Auto"). Tag "Garage" ou "Particulier".
    * Aperçu du dernier message (ex: "RDV confirmé jeudi 10h ✓").
    * Heure ou jour à droite (ex: "09:42").
    * Point orange pour les messages non lus avec le nombre.

### 4.2. Chat - Conversation
* **Header :** Bouton retour. Infos du contact (Avatar, Nom "Garage Elite Auto", statut "En ligne"). Bouton "Certifié".
* **Contexte de l'annonce :** Petite carte cliquable en haut du chat avec la photo de la voiture et son prix.
* **Zone de messages :**
    * Messages envoyés (Bleu nuit, texte blanc, alignés à droite).
    * Messages reçus (Gris clair, texte sombre, alignés à gauche).
    * **Composant riche de RDV :** Carte dans la conversation "PROPOSITION RDV", date/heure, description, et deux boutons d'action "Confirmer" (Vert) et "Reporter" (Blanc).
* **Barre de saisie (Bas) :** Icône trombone (pièce jointe), champ "Message...", icône micro, bouton envoyer circulaire orange. Au-dessus de la zone de texte, des puces de suggestion rapides (ex: "📍 Itinéraire", "💰 Négocier").

### 4.3. Profil (Mon compte)
* **Header (Carte Bleu Nuit étendue) :** Avatar de l'utilisateur. Nom "Abena Mbala", localisation "Bonapriso, Douala". Badges "Vendeur Pro" et "✓ Compte vérifié". Icône soleil/lune pour le mode sombre.
* **Section Activité (Liste) :**
    * "Mes annonces" (6 >)
    * "Mes favoris" (12 >)
    * "Annonces consultées" (28 >)
    * "Mes RDV garages" (2 >)
* **Section PRO - GARAGE :**
    * "Mon garage - Bonapriso Motors"
    * "Booster une annonce"

---

## 5. Modales, Pop-ups & États (Bottom Sheets)

### 5.1. Modale : Annonce publiée (Succès)
* **Type :** Bottom-sheet (panneau glissant du bas) sur fond assombri.
* **Contenu :** Grosse icône de validation (Check vert dans cercle clair). 
* **Texte :** Titre "Annonce publiée !". Paragraphe : "Votre Toyota Hilux Revo est en modération. Visible publiquement sous 30 min."
* **Mini-carte :** Rappel de l'annonce publiée (image, nom, prix, badge VIN).
* **Actions :** Bouton primaire orange "Voir mon annonce", texte secondaire en dessous "Retour à l'accueil".

### 5.2. Modale : Invité bloqué (Authentification requise)
* **Type :** Bottom-sheet sur fond assombri.
* **Contenu :** Icône de bouclier (Sécurité).
* **Texte :** Titre "Connectez-vous pour continuer.". Paragraphe : "Créer un compte prend 30 secondes. Vendez, discutez et sauvegardez vos favoris."
* **Actions :** Bouton primaire orange "Créer un compte", Bouton secondaire bordure noire "J'ai déjà un compte", lien discret en bas "Continuer en invité".

### 5.3. Modale : VIN Invalide (Erreur)
* **Type :** Pop-up centrale (Modal box) sur fond assombri.
* **Contenu :** Icône croix rouge "X" dans un cercle clair.
* **Texte :** Titre "VIN invalide". Paragraphe : "Le numéro **JT1DE12E88612** ne fait que 13 caractères. Un VIN valide en contient 17."
* **Boîte d'astuce (Gris clair) :** Icône clé, texte : "Astuce : vérifiez sur la carte grise ou le montant de la porte conducteur."
* **Actions :** Bouton primaire orange "Réessayer", lien en dessous "Obtenir de l'aide".