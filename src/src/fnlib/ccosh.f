      COMPLEX FUNCTION CCOSH (Z)
C APRIL 1977 VERSION.  W. FULLERTON, C3, LOS ALAMOS SCIENTIFIC LAB.
C JUNE 2000  Changed CCOS to generic COS
      COMPLEX Z, CI
      DATA CI /(0.,1.)/
C
      CCOSH = COS (CI*Z)
C
      RETURN
      END