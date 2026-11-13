// Motion layer (GSAP). Everything is visible without it: animations only run from a hidden state
// when the reader has not asked for reduced motion, and every effect is reverted on unmount.
import { useLayoutEffect, useRef } from 'react'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import { SplitText } from 'gsap/SplitText'

gsap.registerPlugin(ScrollTrigger, SplitText)

const MOTION_OK = '(prefers-reduced-motion: no-preference)'

/**
 * Hero entrance, played once per mount (or when `deps` change).
 * Inside the returned ref: [data-split] headlines rise line by line behind a mask,
 * [data-e] elements follow in order, [data-e-img] wipes open.
 */
export function useEnter(deps = []) {
  const ref = useRef(null)
  useLayoutEffect(() => {
    if (!ref.current) return undefined
    const mm = gsap.matchMedia(ref)
    mm.add(MOTION_OK, () => {
      const q = gsap.utils.selector(ref)
      q('[data-split]').forEach((el) => {
        // autoSplit re-splits when the web font arrives or the width changes, so lines never break wrong
        SplitText.create(el, {
          type: 'lines', mask: 'lines', autoSplit: true,
          onSplit: (self) => gsap.from(self.lines, { yPercent: 110, duration: 0.95, stagger: 0.09, ease: 'power4.out' }),
        })
      })
      gsap.from(q('[data-e]'), { y: 26, autoAlpha: 0, duration: 0.8, stagger: 0.07, delay: 0.25, ease: 'power3.out', clearProps: 'all' })
      gsap.fromTo(q('[data-e-img]'), { clipPath: 'inset(0% 0% 100% 0%)' },
        { clipPath: 'inset(0% 0% 0% 0%)', duration: 1.2, ease: 'power4.inOut', clearProps: 'clipPath' })
      gsap.from(q('[data-e-img] img'), { scale: 1.12, duration: 1.6, ease: 'power3.out', clearProps: 'all' })
    })
    return () => mm.revert()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)
  return ref
}

/** Page headers of the inner pages (Latest, Attention, About, search…): their lines rise once per route. */
export function usePageEnter(pathname) {
  useLayoutEffect(() => {
    const mm = gsap.matchMedia()
    mm.add(MOTION_OK, () => {
      const items = gsap.utils.toArray('#main .page-hero .container > *')
      if (items.length) gsap.from(items, { y: 24, autoAlpha: 0, duration: 0.7, stagger: 0.06, ease: 'power3.out', clearProps: 'all' })
    })
    return () => mm.revert()
  }, [pathname])
}

/** The statement: its words go from grey to ink as the section crosses the screen (scroll-scrubbed). */
export function useWordHighlight() {
  const ref = useRef(null)
  useLayoutEffect(() => {
    if (!ref.current) return undefined
    const mm = gsap.matchMedia(ref)
    mm.add(MOTION_OK, () => {
      gsap.fromTo(gsap.utils.selector(ref)('[data-w]'), { opacity: 0.16 }, {
        opacity: 1, stagger: 0.12, ease: 'none',
        scrollTrigger: { trigger: ref.current, start: 'top 78%', end: 'bottom 55%', scrub: 0.4 },
      })
    })
    return () => mm.revert()
  }, [])
  return ref
}
