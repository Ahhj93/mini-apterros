# Contribution
## Règles des commits
Les messages de commit doivent respecter les Conventional Commits.

### Format recommandé
type(scope)?: sujet court

### Regles
- type est obligatoire et en minuscule.
- scope est optionnel et decrit la zone impactee (ex: api, ui, hardware, docs).
- sujet court.
- une ligne vide, puis un corps optionnel avec plus de details.
- pour un changement non retrocompatible, ajouter ! apres le type ou le scope.

### Types usuels
- feat: nouvelle fonctionnalite.
- fix: correction de bug.
- docs: documentation uniquement.
- style: formatage, espaces, pas de changement fonctionnel.
- refactor: refactorisation sans changement de comportement.
- perf: amelioration de performance.
- test: ajout ou correction de tests.
- build: changement qui impacte le build ou les dependances.
- ci: changements de configuration CI.
- chore: taches diverses, pas de changement prod.
- revert: annulation d'un commit précédent.

### Exemples
- feat(ui): ajouter le bouton de paiement
- fix(api): corriger la validation des montants
- docs: expliquer la procédure de montage
- refactor(hardware): simplifier le schéma d'alimentation
- feat!: changer le format des trames

### Corps de message (optionnel)
Explique le contexte, le pourquoi, et les impacts. Si besoin, ajoute une section "BREAKING CHANGE:".