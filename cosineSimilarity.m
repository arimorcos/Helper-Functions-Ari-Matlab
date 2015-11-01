function out = cosineSimilarity(x1, x2)

out = (x1'*x2)/(norm(x1)*norm(x2));