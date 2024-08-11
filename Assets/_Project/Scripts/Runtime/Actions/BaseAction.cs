using System;
using UnityEngine;

[RequireComponent(typeof(Unit))]
public abstract class BaseAction : MonoBehaviour
{
   public delegate void ActionCompleteDelegate();

   protected Unit unit;
   protected bool isActive;
   protected Action onActionComplete;

   protected virtual void Awake()
   {
      unit = GetComponent<Unit>();
   }

   public abstract string GetActionName();
}
