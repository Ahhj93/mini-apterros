# MiniApterros : équivalent MATLAB des VI LabVIEW

Construit à partir de 38 VI + `Code_principal.lvproj` (cible d'origine : NI myRIO-1900).
Testé sous Octave (`test_all.m`) ; pas testé sous MATLAB ni sur le matériel.

| VI LabVIEW | Fichier MATLAB |
|---|---|
| Table_controle (VI principal) | `main_control.m`, `default_config.m` |
| PID_Altitude | `pid_altitude.m` (+ `_state`) |
| PID_Pitch, PID_Roll, PID_Yaw | `pid_attitude.m` (+ `_state`) |
| Angle_plateau_1 / 2 | `pid_mcc_angle.m` (+ `_state`) |
| Vitesse_MCC_1 / 2 | `motor_drive.m` |
| Turbines | `turbines_mix.m`, `turbines_write.m` |
| Remise_a_zero_moteurs | `outputs_zero.m` |
| Lecture_angle_MCC1 / 2 | `hall_read_angle.m` (+ `hall_state.m`) |
| Initialisation_Lidar | `lidar_init.m` |
| Mesure_Lidar1 / 2 / Latéral | `lidar_read.m` (+ `lidar_state.m`) |
| Changement_adresse_Lidar, Reinitialisation_Lidar | `lidar_change_address.m`, `lidar_reinit_address.m` |
| Initialisation_Xsens, Lecture_Xsens, IMU_v2 | `xsens_init.m`, `xsens_read.m`, `xsens_parse.m`, `xbus_frame.m`, `xsens_state.m` |
| VI_Moteur_CC_v2 (simulation du moteur) | `motor_cc_model.m` |
| Globalvi, Capteurs_Angles, Lidars_v2 | champs de `cfg` / structures d'état, `main_control.m` |

Non convertis : les VI `Test_*` (bancs d'essai qui appellent les VI ci-dessus), `Reset_MyRio`
(reset FPGA, sans objet hors LabVIEW), `Table_observation` (affichage côté PC en Wi-Fi).

## À compléter / à vérifier

- **Couche matérielle** : `hw_sim.m` simule le matériel. Écrire `hw_real.m` avec les 4 mêmes
  fonctions (I2C, sortie numérique, PWM) selon la carte utilisée.
- **Gains** : `default_config.m` contient des placeholders (Kp, Ti, Td, Tr, Tad, T du moteur).
- **Hypothèses signalées `HYPOTHESE` dans `main_control.m`** : altitude = moyenne des 2 lidars,
  valeurs mesurées relatives aux valeurs au repos, tangage -> plateau 1 et lacet -> plateau 2
  (échelle ±70°).
- **Autres points incertains** : lien w1/w2 -> canaux PWM et formule de la poussée (`turbines_mix`),
  rôle de la constante 0.6 (`motor_drive`), sorties de sens complémentaires, rôle de 57.8 (Hall),
  ordre des écritures de `lidar_init`, messages Xsens à valider sur le capteur.
- **Mode libre** (curseurs manuels) de Table_controle : non reproduit.

## Simulation complète (sans matériel)

`apteros_simulation.m` fait tourner toute la boucle fermée numériquement (aucun appel matériel),
avec un modèle physique approximatif de l'engin (`apteros_physics_*.m`) : masse, inerties et bras
de levier sont des **placeholders**, aucun VI ne donne ces valeurs.

```matlab
res = apteros_simulation();                          % 10 s, consignes par défaut, trace les courbes
res = apteros_simulation(20, struct('roll_deg', 10)); % 20 s, consigne de roulis à 10°
res = apteros_simulation(10, [], false);              % sans figure, juste res.log
```

## Chiffrer la performance (pour une présentation)

`apteros_performance_report.m` envoie un échelon sur chaque boucle (altitude, roulis, tangage,
lacet) et calcule temps de montée, dépassement, temps de stabilisation et erreur statique
(`step_metrics.m`, calcul manuel, sans Control System Toolbox) :

```matlab
T = apteros_performance_report();          % 15 s par boucle, avec les 4 figures
T = apteros_performance_report(15, false); % sans figures
```

Avec les gains placeholders actuels, les dépassements sont élevés (40 à 80 %) et l'altitude ne
rentre pas dans la bande de stabilisation à 5 % : c'est le signe que les gains doivent être réglés
avant de présenter ces courbes. Une fois de meilleurs gains trouvés dans `default_config.m`, relance
le rapport pour obtenir des chiffres présentables.
