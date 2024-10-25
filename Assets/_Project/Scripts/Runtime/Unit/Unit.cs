using System;
using UnityEngine;

[RequireComponent(
   typeof(HealthSystem)
)]
public class Unit : MonoBehaviour
{
   public event EventHandler OnMouseOverUnitChanged;
   public static event EventHandler OnAnyAcionPointsChanged;
   public static event EventHandler OnAnyUnitSpawned;
   public static event EventHandler OnAnyUnitDead;

   private const int MAX_ACTION_POINTS = 9;

   [SerializeField]
   private bool isEnemy;

   private GridPosition gridPosition;
   private HealthSystem healthSystem;
   private BaseAction[] baseActions;
   private int actionPoints = MAX_ACTION_POINTS;
   private bool isMouseOver;

   private void Awake()
   {
      healthSystem = GetComponent<HealthSystem>();
      baseActions = GetComponents<BaseAction>();
   }

   private void Start()
   {
      gridPosition = LevelGrid.Instance.GetGridPosition(transform.position);

      LevelGrid.Instance.AddUnitAtGridPosition(gridPosition, this);

      TurnSystem.Instance.OnTurnChanged += TurnSystem_OnTurnChanged;

      healthSystem.OnDead += HealthSystem_OnDead;

      OnAnyUnitSpawned?.Invoke(this, EventArgs.Empty);
   }

   private void Update()
   {
      GridPosition newGridPosition = LevelGrid.Instance.GetGridPosition(transform.position);

      if(newGridPosition != gridPosition)
      {
         GridPosition lastGridPosition = gridPosition;
         gridPosition = newGridPosition;
         LevelGrid.Instance.UnitMovedGridPosition(this, lastGridPosition, newGridPosition);
      }
   }

   private void OnMouseEnter()
   {
      isMouseOver = true;
      OnMouseOverUnitChanged?.Invoke(this, EventArgs.Empty);
   }

   private void OnMouseExit()
   {
      isMouseOver = false;
      OnMouseOverUnitChanged?.Invoke(this, EventArgs.Empty);
   }

   public T GetAction<T>() where T : BaseAction
   {
      foreach (BaseAction action in baseActions)
      {
         if (action is T)
         {
            return (T)action;
         }
      }

      return null;
   }

   public GridPosition GetGridPosition()
   {
      return gridPosition;
   }

   public Vector3 GetWorldPosition()
   {
      return transform.position;
   }

   public BaseAction[] GetBaseActions()
   {
      return baseActions;
   }

   public bool TrySpendActionPoints(BaseAction baseAction)
   {
      if (HasEnoughActionPoints(baseAction))
      {
         SpendActionPoints(baseAction.GetActionPointsCost());
         return true;
      }

      return false;
   }

   public bool HasEnoughActionPoints(BaseAction baseAction)
   {
      return actionPoints >= baseAction.GetActionPointsCost();
   }

   private void SpendActionPoints(int amount)
   {
      actionPoints -= amount;

      OnAnyAcionPointsChanged?.Invoke(this, EventArgs.Empty);
   }

   public int GetActionPoints()
   {
      return actionPoints;
   }

   private void TurnSystem_OnTurnChanged(object sender, EventArgs e)
   {
      if((IsEnemy() && !TurnSystem.Instance.IsPlayerTurn()) ||
         (!IsEnemy() && TurnSystem.Instance.IsPlayerTurn()))
      {
         actionPoints = MAX_ACTION_POINTS;

         OnAnyAcionPointsChanged?.Invoke(this, EventArgs.Empty);
      }
   }

   public bool IsMouseOver()
   {
      return isMouseOver;
   }

   public bool IsEnemy()
   {
      return isEnemy;
   }

   public void TakeDamage(int damage)
   {
      healthSystem.TakeDamage(damage);
   }

   private void HealthSystem_OnDead(object sender, EventArgs e)
   {
      LevelGrid.Instance.RemoveUnitAtGridPosition(gridPosition, this);
      Destroy(gameObject);
      OnAnyUnitDead?.Invoke(this, EventArgs.Empty);
   }

   public float GetHealthNormalized()
   {
      return healthSystem.GetHealthNormalized();
   }
}
