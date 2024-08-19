using System;
using System.Collections.Generic;
using UnityEngine;

public class UnitManager : Singleton<UnitManager>
{
   private List<Unit> units;
   private List<Unit> friendlyUnits;
   private List<Unit> enemyUnits;

   protected override void Awake()
   {
      base.Awake();
      units = new List<Unit>();
      friendlyUnits = new List<Unit>();
      enemyUnits = new List<Unit>();
   }

   private void Start()
   {
      Unit.OnAnyUnitSpawned += Unit_OnAnyUnitSpawned;
      Unit.OnAnyUnitDead += Unit_OnAnyUnitDead;
   }

   private void Unit_OnAnyUnitSpawned(object sender, EventArgs e)
   {
      Unit unit = sender as Unit;
      units.Add(unit);

      if (unit.IsEnemy()) enemyUnits.Add(unit);
      else friendlyUnits.Add(unit);
   }

   private void Unit_OnAnyUnitDead(object sender, EventArgs e)
   {
      Unit unit = sender as Unit;
      units.Remove(unit);

      if (unit.IsEnemy()) enemyUnits.Remove(unit);
      else friendlyUnits.Remove(unit);
   }

   public List<Unit> GetAllUnits()
   {
      return units;
   }

   public List<Unit> GetFriendlyUnits()
   {
      return friendlyUnits;
   }

   public List<Unit> GetEnemyUnits()
   {
      return enemyUnits;
   }
}