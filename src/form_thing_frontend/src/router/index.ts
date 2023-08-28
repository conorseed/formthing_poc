import { createRouter, createWebHistory, START_LOCATION } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { nextTick } from 'vue'
import { useNotificationStore } from '@/stores/useNotificationStore'

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
      path: '/admin',
      component: () => import('@/views/AdminView.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'admin',
          component: () => import('@/components/AdminFormsPage.vue'),
          meta: { requiresAuth: true, title: 'Forms' }
        },
        {
          path: 'form/:formId',
          name: 'adminFormSingle',
          component: () => import('@/components/AdminFormSinglePage.vue'),
          meta: { requiresAuth: true, title: 'Form Details' }
        },
        {
          path: 'form/create',
          name: 'adminFormCreate',
          component: () => import('@/components/AdminCreateFormPage.vue'),
          meta: { requiresAuth: true, title: 'Create Form' }
        }
      ]
    },
    {
      path: '/forms/',
      component: () => import('@/views/PublicFormView.vue'),
      children: [
        {
          path: ':formId',
          name: 'formSingle',
          component: () => import('@/components/PublicFormPage.vue')
        }
      ]
    },
    // otherwise redirect to home
    { path: '/:pathMatch(.*)*', name: 'NotFound', redirect: { name: 'home' } }
  ]
})

// Check if the route requires authentication
router.beforeEach(async (to, from) => {
  const authStore = useAuthStore()
  // first try to login
  if (from === START_LOCATION) {
    const res = await authStore.login_retry()
    if (res) {
      // add notification
      useNotificationStore().addNotification({
        title: 'Welcome Back',
        message: "You've been automatically logged in from a previous session.",
        status: 'success'
      })
    }
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

// Focus the body on route change
router.afterEach((from, to) => {
  if (from.path !== to.path) {
    nextTick(() => {
      document.body.tabIndex = 0
      document.body.focus()
      document.body.tabIndex = -1
    })
  }
})

// declare types
declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth: boolean
    title?: string
  }
}

export default router
