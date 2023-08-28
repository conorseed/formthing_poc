import { ref } from 'vue'
import { defineStore } from 'pinia'

type Notification = {
  id: string
  title: string
  message: string
  status: 'loading' | 'success' | 'error'
}

type NotificationWithoutId = Omit<Notification, 'id'>

export const useNotificationStore = defineStore('notification', () => {
  const notifications = ref<Notification[]>([])

  const addNotification = (newNotification: NotificationWithoutId) => {
    const notification = {
      ...newNotification,
      id: Math.random().toString(36).substr(2, 9)
    }
    notifications.value.push(notification)
    removeNotificationAfterTimeout(notification.id)
    return notification.id
  }

  const removeNotification = (notification_id: string) => {
    notifications.value = notifications.value.filter(
      (notification) => notification.id !== notification_id
    )
  }

  // update notification status
  const updateNotification = (
    notification_id: string,
    updated_notification: NotificationWithoutId
  ) => {
    const notification = notifications.value.find(
      (notification) => notification.id === notification_id
    )
    if (!notification) return
    Object.assign(notification, updated_notification)
    removeNotificationAfterTimeout(notification_id)
  }

  // maybe add a timeout to remove notification after a certain amount of time if status is not loading
  // default timeoput is 5 seconds
  const removeNotificationAfterTimeout = (notification_id: string, timeout: number = 5000) => {
    const notification = notifications.value.find(
      (notification) => notification.id === notification_id
    )
    if (notification && notification.status === 'loading') return
    setTimeout(() => {
      removeNotification(notification_id)
    }, timeout)
  }

  return {
    notifications,
    addNotification,
    removeNotification,
    updateNotification
  }
})
