export function useGeneralUtils() {
  const formatDate = (nanoseconds: bigint) => {
    const date = new Date(parseInt(nanoseconds.toString()) / 1000000)
    return new Intl.DateTimeFormat('en-US', {
      dateStyle: 'short',
      timeStyle: 'short'
    }).format(date)
  }

  const sanitizeHTML = (input: string): string => {
    return input.replace(/<[^>]*>/g, '') // Removes all HTML tags
  }

  return { formatDate, sanitizeHTML }
}
