using System;
using UnityEngine;
using UnityEngine.UI;

public class HealthSystem : MonoBehaviour
{
   public event EventHandler OnDead;
   //public event EventHandler OnHealed;

   [SerializeField]
   private Material fullHealthColor;
   [SerializeField]
   private Material halfHealthColor;
   [SerializeField]
   private Material lowHealthColor;
   [SerializeField]
   private Image healthBarImage;
   [SerializeField]
   private int maxHealth = 100;

   private int health = 100;

   private void Awake()
   {
      health = maxHealth;
      healthBarImage.fillAmount = 1;
      SetHealthColor();
   }

   public void TakeDamage(int damage)
   {
      health -= damage;

      if (health <= 0)
      {
         health = 0;
         Die();
      }
      healthBarImage.fillAmount = (float)health / maxHealth;
      SetHealthColor();
   }

   private void SetHealthColor()
   {
      if (health >= (maxHealth / 3) * 2)
      {
         healthBarImage.material = fullHealthColor;
      }
      else if (health >= maxHealth / 3)
      {
         healthBarImage.material = halfHealthColor;
      }
      else
      {
         healthBarImage.material = lowHealthColor;
      }
   }

      private void Die()
   {
      OnDead?.Invoke(this, EventArgs.Empty);
   }
}
