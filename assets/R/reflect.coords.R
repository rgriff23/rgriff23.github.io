# function to reflect 3D points across the plane of symmetry of an object
reflect.coords <- function (mat, midline, reflect) {
  
  # mean of midline points
  m <- colMeans(mat[midline,])
  
  # normal to saggital plane
  n <- prcomp(mat[midline,])$rotation[,3] 
  
  # distance from m to the plane defined by n at the origin
  d <- sum(-m*n) 
  
  # translate points so midline is at origin
  r <-  t(mat[reflect,]) + d*n 
  
  # Householder transformation (reflection) matrix
  A <- diag(3) - 2*n%*%t(n) 
  
  # reflect and reverse-translate
  z <- ifelse(nrow(r)==1, 1, 2) 
  mat[reflect,] <- t(apply(r, z, function(x) A%*%x))  - d*n
  
  # round and return matrix
  return(round(mat, 2))
}

# example usage
#mat <- matrix(c(0,2,0,0,2,1,0,0,2,0,-1,1,3,0,0,2,0,1), nrow=6,ncol=3, byrow=T, dimnames=list(c("m1","m2","m3","m4","b1","b2"), c("x","y","z")))
#midline <- c("m1","m2","m3","m4")
#reflect <- c("b1","b2")
#reflect.coords(mat, midline, reflect)