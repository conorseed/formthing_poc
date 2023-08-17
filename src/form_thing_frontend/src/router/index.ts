import { createRouter, createWebHistory, START_LOCATION } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { nextTick } from 'vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: () => import('@/views/MainView.vue'),
      children: [
        {
          path: '/',
          name: 'home',
          component: () => import('@/components/HomePage.vue')
        },
        {
          path: '/login',
          name: 'login',
          component: () => import('@/components/LoginPage.vue')
        }
      ]
    },
    {
      path: '/account',
      component: () => import('@/views/MainView.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'account',
          component: () => import('@/components/FormsPage.vue')
        }
      ]
    }
  ]
})

// Check if the route requires authentication
router.beforeEach(async (to, from) => {
  const authStore = useAuthStore()
  // first try to login
  if (from === START_LOCATION) {
    await authStore.login_retry()
  }
  // check if the route requires authentication
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    // check if the user is logged in
    if (!(await authStore.isAuthenticated())) {
      // redirect to login page
      return { name: 'login' }
    }
  }
})

router.afterEach((from, to) => {
  if (from.path !== to.path) {
    nextTick(() => {
      document.body.tabIndex = 0
      document.body.focus()
      document.body.tabIndex = -1
    })
  }
})

export default router
