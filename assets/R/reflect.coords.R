# function to reflect 3D points across the plane of symmetry of an object
reflect.coords <- function (mat, midline, reflect) {
  m <- colMeans(mat[midline,]) # mean of midline points
  n <- prcomp(mat[midline,])$rotation[,3] # normal to saggital plane
  d <- sum(-m*n) # distance from m to the plane defined by n at the origin
  r <-  t(mat[reflect,]) + d*n # translate points so midline is at origin
  A <- diag(3) - 2*n%*%t(n) # Householder transformation (reflection) matrix
  z <- ifelse(nrow(r)==1, 1, 2) 
  mat[reflect,] <- t(apply(r, z, function(x) A%*%x))  - d*n # reflect and reverse-translate
  return(mat)
}

# example usage
#mat <- matrix(c(0,2,0,0,2,1,0,0,2,0,-1,1,3,0,0,2,0,1), nrow=6,ncol=3, byrow=T, dimnames=list(c("m1","m2","m3","m4","b1","b2"), c("x","y","z")))
#midline <- c("m1","m2","m3","m4")
#reflect <- c("b1","b2")
#reflect.coords(mat, midline, reflect)